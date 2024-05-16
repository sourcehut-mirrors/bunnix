use errors::{error, errno};
use io;

// Serial device.
export type serialdev = struct {
	serial_impl: const nullable *serial_iface,
	cons: serialcons,
};

// Serial console device.
export type serialcons = struct {
	io::file,
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
	dev.cons.vtable = &serial_file_vtable;
	cons_register(&dev.cons);
};

export const serial_file_vtable = io::vtable {
	write = &serial_write,
	...
};

fn serial_write(cons: *io::file, buf: const []u8) (size | error) = {
	const cons = cons: *serialcons;
	const dev = cons.dev: *serialdev;
	const impl = dev.serial_impl as *serial_iface;
	return impl.write(dev, buf);
};
