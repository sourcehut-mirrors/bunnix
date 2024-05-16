use errors::{error, errno};
use io;

export type chardev = struct {
	iface: const nullable *chardev_iface,
	major: u32,
	minor: u32,
};

// Opens a character device as a file.
export type fn_chardev_open = fn(cdev: *chardev) (*io::file | error);

// Interface for a character device.
export type chardev_iface = struct {
	open: *fn_chardev_open,
};

let devs: []*chardev = [];

// Registers a new character device.
export fn register(dev: *chardev) void = {
	if (len(devs) == 0) {
		static let buf: [256]nullable *chardev = [null...];
		devs = buf[..0]: []*chardev;
	};

	// TODO: Binary search by device number
	static append(devs, dev);
};

// Finds a character device with the given device number.
export fn lookup(major: u32, minor: u32) (*chardev | error) = {
	for (let dev .. devs) {
		if (dev.major == major && dev.minor == minor) {
			return dev;
		};
	};
	return errno::NXIO;
};

// Opens a character device with the given major/minor number assignment.
export fn open(major: u32, minor: u32) (*io::file | error) = {
	const dev = lookup(major, minor)?;
	const iface = dev.iface as *chardev_iface;
	return iface.open(dev);
};
