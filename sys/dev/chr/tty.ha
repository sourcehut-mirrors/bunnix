use dev;
use errors::{error, errno};
use fmt;
use io;
use mman;
use poll;
use sched;

// Forward declaration
fn proc::ctty() u64;

def BUFSIZ: size = 1024;

// TTY device.
export type tty = struct {
	chardev,
	tty_iface: const nullable *tty_iface,
	buffer: []u8,
	avail: []u8,
	eof: bool,
	refs: int,
	tios: termios,

	wq: sched::wq_head,
	poll: poll::event_source,
};

// TTY device implementation.
export type tty_iface = struct {
	write: *fn(tty: *tty, buf: const []u8) (size | error),
	getwinsz: *fn(tty: *tty) (uint, uint),
};

let ttys: []*tty = [];

// Initializes a TTY.
export fn tty_init(tty: *tty, serial: bool) void = {
	assert(tty.tty_iface != null);
	tty.iface = &tty_chardev_impl;
	tty.major = dev::TTY_MAJOR;
	tty.buffer = alloc([0...], BUFSIZ);
	tty.avail = tty.buffer[..0];
	termios_init(&tty.tios);

	if (serial) {
		static let nserial = 0u32;
		tty.minor = dev::TTYS_MINOR + nserial;
		nserial += 1;
	} else {
		static let nother = 0u32;
		tty.minor = nother;
		nother += 1;
	};

	append(ttys, tty);

	register(tty);
};

// chardev for /dev/tty psuedo-device, opens the user's controlling terminal
const devtty = chardev {
	iface = &devtty_impl,
	major = dev::TTY_ALT_MAJOR,
	minor = dev::DEVTTY_MINOR,
};

const devtty_impl = chardev_iface {
	open = &devtty_open,
};

fn devtty_open(cdev: *chardev) (*io::file | error) = {
	const ctty = proc::ctty();
	const major = (ctty >> 32): u32;
	const minor = ctty: u32;
	return open(major, minor);
};

// Populates /dev with TTY devices
export fn mounttty(root: *io::inode) void = {
	let namebuf: [32]u8 = [0...];
	for (let tty .. ttys) {
		const name = if (tty.minor >= dev::TTYS_MINOR) {
			yield fmt::bsprintf(namebuf, "ttyS{}",
				tty.minor - dev::TTYS_MINOR);
		} else {
			yield fmt::bsprintf(namebuf, "tty{}", tty.minor);
		};

		io::inode_mknod(root, name, 0o660 | io::mode::CHR,
			dev::mkdev(tty.major, tty.minor))!;
	};

	register(&devtty);
	io::inode_mknod(root, "tty", 0o660 | io::mode::CHR,
		dev::mkdev(devtty.major, devtty.minor))!;
};

// Puts a character to this tty.
export fn tty_putc(tty: *tty, c: u8) void = {
	if (tty.refs == 0) {
		return;
	};
	if (len(tty.avail) >= len(tty.buffer)) {
		return; // Drop input
	};

	let add = true;
	switch (c) {
	case '\r' =>
		if (tty.tios.c_iflag & ICRNL != 0) {
			c = '\n';
		};
		if (tty.tios.c_iflag & IGNCR != 0) {
			return;
		};
	case '\n' =>
		if (tty.tios.c_iflag & INLCR != 0) {
			c = '\r';
		};
	case '\b' =>
		if (tty.tios.c_lflag & ICANON != 0) {
			if (len(tty.avail) == 0) {
				return;
			};
			static delete(tty.avail[len(tty.avail)-1]);
			add = false;
		};
	case '\x7f' =>
		// XXX HACK
		add = false;
	case '\x04' =>
		if (len(tty.avail) == 0) {
			tty.eof = true;
			sched::wake(&tty.wq);
			poll::signal(&tty.poll, poll::POLLIN);
		};
		return;
	case => void;
	};

	if (add) {
		static append(tty.avail, c);
	};

	if (tty.tios.c_lflag & ECHO != 0) {
		const iface = tty.tty_iface as *tty_iface;
		iface.write(tty, [c])!;
	};

	if (tty.tios.c_lflag & ICANON == 0 || c == '\n' || len(tty.avail) == len(tty.buffer)) {
		sched::wake(&tty.wq);
		poll::signal(&tty.poll, poll::POLLIN);
	};
};

const tty_chardev_impl = chardev_iface {
	open = &tty_open,
};

fn tty_open(cdev: *chardev) (*io::file | error) = {
	let tty = cdev: *tty;
	tty.refs += 1;
	return alloc(tty_file {
		vtable = &tty_file_impl,
		tty = tty,
		...
	});
};

type tty_file = struct {
	io::file,
	tty: *tty,
};

const tty_file_impl = io::vtable {
	read = &tty_read,
	write = &tty_write,
	ioctl = &tty_ioctl,
	poll = &tty_poll,
	finish = &tty_finish,
	...
};

fn tty_read(tty: *io::file, buf: []u8) (size | io::EOF | error) = {
	const file = tty: *tty_file;
	const tty = file.tty;

	let wq = sched::wq_link { ... };
	for (len(tty.avail) == 0 && !tty.eof) {
		sched::wait(&tty.wq, &wq);
	};
	if (tty.eof) {
		tty.eof = false;
		return io::EOF;
	};

	let ncopy = len(tty.avail);
	if (ncopy > len(buf)) {
		ncopy = len(buf);
	};

	buf[..ncopy] = tty.avail[..ncopy];
	static delete(tty.avail[..ncopy]);

	if (len(tty.avail) < len(tty.buffer)) {
		poll::signal(&tty.poll, poll::POLLOUT);
	};

	return ncopy;
};

fn tty_write(tty: *io::file, buf: const []u8) (size | error) = {
	const file = tty: *tty_file;
	const tty = file.tty;
	const iface = tty.tty_iface as *tty_iface;
	const n = iface.write(tty, buf);
	poll::signal(&tty.poll, poll::POLLIN);
	return n;
};

fn tty_poll(tty: *io::file, poll: *io::pollfd) (u64 | error) = {
	const file = tty: *tty_file;
	const tty = file.tty;

	let events = 0u64;
	if (poll.events & poll::POLLOUT != 0) {
		if (len(tty.avail) < len(tty.buffer)) {
			poll.revents |= poll::POLLOUT;
			events = 1;
		};
	};
	if (poll.events & poll::POLLIN != 0) {
		if (len(tty.avail) != 0) {
			poll.revents |= poll::POLLIN;
			events = 1;
		};
	};

	if (events == 0) {
		poll::register(&tty.poll, poll);
	};

	return events;
};

fn tty_ioctl(tty: *io::file, req: uint, arg: u64) (u64 | error) = {
	let file = tty: *tty_file;
	let tty = file.tty;
	const iface = tty.tty_iface as *tty_iface;

	switch (req) {
	case io::TIOCGWINSZ =>
		let wsize = arg: uintptr: *winsize;
		if (!mman::isvalid(wsize, size(winsize), true)) {
			return errno::FAULT: error;
		};
		const (rows, cols) = iface.getwinsz(tty);
		wsize.ws_row = rows: u16;
		wsize.ws_col = cols: u16;
		return 0u64;
	case io::TCGETS =>
		let tios = arg: uintptr: *termios;
		if (!mman::isvalid(tios, size(termios), true)) {
			return errno::FAULT: error;
		};
		*tios = tty.tios;
		return 0u64;
	case io::TCSETS, io::TCSETSW, io::TCSETSF =>
		let tios = arg: uintptr: *termios;
		if (!mman::isvalid(tios, size(termios))) {
			return errno::FAULT: error;
		};
		tty.tios = *tios;
		return 0u64;
	case =>
		return errno::INVAL: error;
	};
};

fn tty_finish(tty: *io::file) void = {
	let tty = tty: *tty_file;
	tty.tty.refs -= 1;
	free(tty);
};
