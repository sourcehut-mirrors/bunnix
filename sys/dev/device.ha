use errors::{error, errno};
use io;
use sort;

// A device on the system, virtual or otherwise.
export type device = struct {
	impl: const *device_iface,
	rdev: u64,
};

// Opens this device's inode.
export type fn_dev_open = fn(dev: *device) (*io::inode | error);

// Device interface.
export type device_iface = struct {
	open: nullable *fn_dev_open,
};

let devs: []*device = [];

// Registers a device with the device list.
export fn register(dev: *device) void = {
	assert(dev.rdev != 0, "dev::register: rdev uninitialized");
	assert(open(dev.rdev) is error,
		"dev::register: attempted to add two devices with same rdev");

	const ix = sort::lbisect(devs, size(*device), dev, &dev_cmp);
	insert(devs[ix], dev);
};

// Opens the requested device.
export fn open(rdev: u64) (*device | error) = {
	const model = device {
		impl = null: const *device_iface,
		rdev = rdev,
	};
	match (sort::search(devs, size(*device), &model, &dev_cmp)) {
	case let i: size =>
		return devs[i];
	case void =>
		return errno::NXIO;
	};
};

fn dev_cmp(a: const *opaque, b: const *opaque) int = {
	const a = a: **device;
	const b = b: **device;
	return if (a.rdev < b.rdev) -1
		else if (a.rdev > b.rdev) 1
		else 0;
};
