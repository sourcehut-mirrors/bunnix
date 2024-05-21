use dev;
use errors::{error, errno};
use io;
use sched;
// XXX TEMP
use log;

def KBD_KEYBUF_SZ: size = 32;

export type kbd_led = enum uint {
	SCROLL_LOCK = 1 << 0,
	NUM_LOCK = 1 << 0,
	CAPS_LOCK = 1 << 0,
};

export type key_state = enum uint {
	PRESSED,
	RELEASED,
};

export type kbd_evdata = struct {
	scancode: u32,
	state: key_state,
};

export type kbd_onproc_cb = fn(scancode: u32, state: key_state, user: nullable *opaque) void;

// Keyboard device.
export type kbd = struct {
	chardev,
	kbd_iface: const *kbd_iface,
	buffer: [KBD_KEYBUF_SZ]kbd_evdata,
	buf: []kbd_evdata,
	wq: sched::wq_head,
	refs: int,

	// Used by drivers which make use of the keyboard internally to the
	// kernel, i.e. the vt driver. Just passes keyboard events straight
	// through.
	onproc: nullable *kbd_onproc_cb,
	onproc_user: nullable *opaque,
};

// Keyboard device implementation.
export type kbd_iface = struct {
	// TODO: ioctl
	set_led: *fn(kbd: *kbd, led: kbd_led) void,
};

// Initializes a keyboard device and registers it as a character device.
export fn kbd_init(kbd: *kbd) void = {
	kbd.buf = kbd.buffer[..0];
	kbd.iface = &kbd_chardev_impl;
	kbd.major = dev::INPUT_MAJOR;
	kbd.minor = dev::KBD_MINOR;
	register(kbd);
};

// Registers a kernel-internal callback for events from this keyboard device.
export fn kbd_onproc(
	kbd: *kbd,
	cb: *kbd_onproc_cb,
	user: nullable *opaque = null,
) void = {
	kbd.onproc = cb;
	kbd.onproc_user = user;
};

// Process input from a keyboard device.
export fn kbd_keyproc(kbd: *kbd, scancode: u32, state: key_state) void = {
	if (kbd.refs == 0) {
		// Only pass through to kernel users if there is no userspace
		// user at the moment
		match (kbd.onproc) {
		case let func: *kbd_onproc_cb =>
			func(scancode, state, kbd.onproc_user);
		case null => void;
		};

		// Don't buffer keyboard events if there's no one to read them
		return;
	};
	if (len(kbd.buf) >= len(kbd.buffer)) {
		// Drop events if we exceed the buffer size
		return;
	};
	static append(kbd.buf, kbd_evdata {
		scancode = scancode,
		state = state,
	});
	sched::wake(&kbd.wq);
};

const kbd_chardev_impl = chardev_iface {
	open = &kbd_open,
};

fn kbd_open(cdev: *chardev) (*io::file | error) = {
	let kbd = cdev: *kbd;
	kbd.refs += 1;
	if (kbd.refs == 1) {
		static delete(kbd.buf[..]);
	};

	return alloc(kbd_file {
		vtable = &kbd_file_impl,
		kbd = kbd,
		...
	});
};

export type kbd_file = struct {
	io::file,
	kbd: *kbd,
};

let kbd_file_impl = io::vtable {
	read = &kbd_read,
	finish = &kbd_finish,
	...
};

fn kbd_read(file: *io::file, buf: []u8) (size | io::EOF | error) = {
	const file = file: *kbd_file;
	const kbd = file.kbd;

	// Must be able to store at least one event
	if (len(buf) < size(kbd_evdata)) {
		return errno::INVAL: error;
	};

	if (file.flag & io::flag::NONBLOCK != 0 && len(kbd.buf) == 0) {
		return errno::AGAIN: error;
	};

	let wait = sched::wq_link { ... };
	for (len(kbd.buf) == 0) {
		sched::wait(&kbd.wq, &wait);
	};

	let n = 0z;
	let events = (buf: *[*]kbd_evdata)[..len(buf) / size(kbd_evdata)];
	for (let i = 0z; len(kbd.buf) != 0 && i < len(events); i += 1) {
		const ev = kbd.buf[0];
		static delete(kbd.buf[0]);
		events[i] = ev;
		n += size(kbd_evdata);
	};
	return n;
};

fn kbd_finish(file: *io::file) void = {
	const file = file: *kbd_file;
	file.kbd.refs -= 1;
	free(file);
};
