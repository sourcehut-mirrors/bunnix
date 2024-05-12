use errors::{error, errno};
use io;

export type chardev = struct {
	iface: const *chardev_iface,
	major: u32,
	minor: u32,
};

export type chardev_iface = struct {
	open: *fn_chardev_open,
};

export type fn_chardev_open = fn(cdev: *chardev) (*io::file | error);

// TODO: This could be grown dynamically if we were a bit more clever, but we
// cannot use the heap during @init
def MAX_DEV: size = 256;
let static_devs: [MAX_DEV]nullable *chardev = [null...];
let devs: []*chardev = [];

// Registers a new character device.
export fn register(dev: *chardev) void = {
	if (len(devs) == 0) {
		devs = static_devs[..0]: []*chardev;
	};

	// TODO: Binary search
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
	return dev.iface.open(dev);
};
