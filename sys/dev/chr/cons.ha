use dev::{devmajor, devminor_tty_alt};
use errors::{error, errno};
use io;

def STATIC_CONSOLES: size = 64;
let static_consoles: [STATIC_CONSOLES]*io::file = [null: *io::file...];

export type console = struct {
	chardev,
	out: []*io::file,
};

const console_impl = chardev_iface {
	open = &cons_open,
};

let cons = console {
	iface = &console_impl,
	major = devmajor::TTY_ALT,
	minor = devminor_tty_alt::CONS,
	out = [],
};

@init fn init() void = {
	register(&cons);
};

// Adds a console to the list of consoles.
export fn cons_register(out: *io::file) void = {
	if (&(cons.out: *[*]*io::file)[0] != &static_consoles[0]) {
		cons.out = static_consoles[..0];
	};

	if (len(cons.out) >= STATIC_CONSOLES) {
		return;
	};

	static append(cons.out, out);
};

fn cons_open(cdev: *chardev) (*io::file | error) = {
	return alloc(io::file {
		vtable = &console_file_impl,
		...
	});
};

let console_file_impl = io::vtable {
	write = &cons_write,
	finish = &cons_finish,
	...
};

fn cons_write(file: *io::file, buf: const []u8) (size | error) = {
	const file = file: *console;
	for (let out .. cons.out) {
		io::writeall(out, buf)!;
	};
	return len(buf);
};

fn cons_finish(file: *io::file) void = {
	free(file);
};
