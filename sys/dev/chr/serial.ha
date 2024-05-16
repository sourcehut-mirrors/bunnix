use errors::{error, errno};
use io;

// Serial device.
export type serialdev = struct {
	serial_impl: const nullable *serial_iface,
	cons: serialcons,
	tty: serialtty,
};

// Serial console device.
export type serialcons = struct {
	io::file,
	dev: nullable *serialdev,
};

export type serialtty = struct {
	tty,
	dev: nullable *serialdev,
};

// Interface for a serial device.
export type serial_iface = struct {
	write: *fn(dev: *serialdev, buf: const []u8) (size | error),
};

// Initializes a serial device, adding it to /dev/cons and creating a serial TTY
// device.
export fn serial_init(dev: *serialdev) void = {
	assert(dev.serial_impl != null);
	dev.cons.dev = dev;
	dev.cons.vtable = &file_vtable;
	cons_register(&dev.cons);
};

export fn serial_tty_init(dev: *serialdev) void = {
	dev.tty.tty_iface = &tty_vtable;
	dev.tty.dev = dev;
	tty_init(&dev.tty, true);
};

const file_vtable = io::vtable {
	write = &serial_write,
	...
};

fn serial_write(cons: *io::file, buf: const []u8) (size | error) = {
	const cons = cons: *serialcons;
	const dev = cons.dev: *serialdev;
	const impl = dev.serial_impl as *serial_iface;
	return impl.write(dev, buf);
};

const tty_vtable = tty_iface {
	write = &serial_tty_write,
	getwinsz = &serial_tty_getwinsz,
};

fn serial_tty_write(tty: *tty, buf: const []u8) (size | error) = {
	const stty = tty: *serialtty;
	const dev = stty.dev: *serialdev;
	return serial_write(&dev.cons, buf);
};

fn serial_tty_getwinsz(tty: *tty) (uint, uint) = {
	return (24, 80);
};

// Report a character input on a serial device.
export fn serial_putc(dev: *serialdev, ch: u8) void = {
	if (dev.tty.tty_iface == null) {
		return;
	};
	tty_putc(&dev.tty, ch);
};
