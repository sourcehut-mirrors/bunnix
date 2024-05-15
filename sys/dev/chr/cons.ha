use dev;
use errors::{error, errno};
use io;

def STATIC_CONSOLES: size = 64;
let static_consoles: [STATIC_CONSOLES]*io::file = [null: *io::file...];

def STATIC_LOG: size = 8192;
let static_log: [STATIC_LOG]u8 = [0...];

export type console = struct {
	chardev,
	out: []*io::file,
	log: []u8,
};

const console_impl = chardev_iface {
	open = &cons_open,
};

let cons = console {
	iface = &console_impl,
	major = dev::TTY_ALT_MAJOR,
	minor = dev::CONS_MINOR,
	out = [],
	log = [],
};

@init fn init() void = {
	register(&cons);
};

// Adds a console to the list of consoles.
export fn cons_register(out: *io::file) void = {
	if (&(cons.out: *[*]*io::file)[0] != &static_consoles[0]) {
		cons.out = static_consoles[..0];
	};
	if (len(cons.log) == 0) {
		cons.log = static_log[..0];
	};

	if (len(cons.out) >= STATIC_CONSOLES) {
		return;
	};

	static append(cons.out, out);
};

// Removes a console file from the list of kernel consoles.
export fn cons_unregister(out: *io::file) void = {
	for (let i = 0z; i < len(cons.out); i += 1) {
		if (cons.out[i] == out) {
			static delete(cons.out[i]);
			break;
		};
	};
};

// Writes data to the kernel console.
export fn cons_write(buf: const []u8) void = {
	for (let out .. cons.out) {
		io::writeall(out, buf)!;
	};

	// TODO: This could/should be a proper ring buffer but I can't be arsed
	if (len(cons.log) + len(buf) >= STATIC_LOG) {
		const diff = STATIC_LOG - (len(cons.log) + len(buf));
		static delete(cons.log[..diff]);
	};
	static append(cons.log, buf...);
};

// Returns the contents of the kernel log buffer.
export fn console_log() []u8 = {
	return cons.log;
};

fn cons_open(cdev: *chardev) (*io::file | error) = {
	return alloc(io::file {
		vtable = &console_file_impl,
		...
	});
};

// A "file" for writing to the kernel console.
export const console_file = io::file {
	vtable = &console_file_impl,
	...
};

const console_file_impl = io::vtable {
	write = &cons_file_write,
	finish = &cons_file_finish,
	...
};

fn cons_file_write(file: *io::file, buf: const []u8) (size | error) = {
	cons_write(buf);
	return len(buf);
};

fn cons_file_finish(file: *io::file) void = {
	free(file);
};
