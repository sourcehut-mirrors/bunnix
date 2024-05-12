use dev;
use errors::{error, errno};
use fmt;
use io;
use sched;

def BUFSIZ: size = 1024;

// TTY device.
export type tty = struct {
	chardev,
	tty_iface: const *tty_iface,
	buffer: []u8,
	avail: []u8,
	refs: int,
	wq: sched::wq_head,
};

// TTY device implementation.
export type tty_iface = struct {
	write: *fn(tty: *tty, buf: const []u8) (size | error),
	getwinsz: *fn(tty: *tty) (uint, uint),
};

let ttys: []*tty = [];

// Initializes a TTY.
export fn tty_init(tty: *tty, serial: bool) void = {
	tty.iface = &tty_chardev_impl;
	tty.major = dev::TTY_MAJOR;
	tty.buffer = alloc([0...], BUFSIZ);
	tty.avail = tty.buffer[..0];

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

// Puts a character to this tty.
export fn tty_putc(tty: *tty, c: u8) void = {
	if (tty.refs == 0) {
		return;
	};
	if (len(tty.avail) >= len(tty.buffer)) {
		return; // Drop input
	};

	static append(tty.avail, c);

	// TODO:
	// - More sophisticated line editing
	// - RAW mode
	// - NOECHO mode

	tty.tty_iface.write(tty, [c])!;

	if (c == '\n' || len(tty.avail) == len(tty.buffer)) {
		sched::wake(&tty.wq);
	};
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
	finish = &tty_finish,
	...
};

fn tty_read(tty: *io::file, buf: []u8) (size | io::EOF | error) = {
	const file = tty: *tty_file;
	const tty = file.tty;

	let wq = sched::wq_link { ... };
	for (len(tty.avail) == 0) {
		sched::wait(&tty.wq, &wq);
	};

	let ncopy = len(tty.avail);
	if (ncopy > len(buf)) {
		ncopy = len(buf);
	};

	buf[..ncopy] = tty.avail[..ncopy];
	static delete(tty.avail[..ncopy]);

	return ncopy;
};

fn tty_write(tty: *io::file, buf: const []u8) (size | error) = {
	const file = tty: *tty_file;
	const tty = file.tty;
	return tty.tty_iface.write(tty, buf);
};

fn tty_finish(tty: *io::file) void = {
	let tty = tty: *tty_file;
	tty.tty.refs -= 1;
	free(tty);
};
