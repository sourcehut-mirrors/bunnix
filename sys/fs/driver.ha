use dev::block;
use errors::{error, errno};

// Filesystem driver implementation.
export type driver = struct {
	name: const str,
	impl: *driver_iface,
	next: nullable *driver,
};

export type fs_opts = struct {
	device: nullable *block::blockdev,
	fstype: str,
	readonly: bool,
	misc: []str,
};

export type fs_driver_open = fn(opts: *fs_opts) (*superblock | error);

export type driver_iface = struct {
	open: *fs_driver_open,
};

let drivers_head: nullable *driver = null;

// Registers a filesystem device driver.
export fn register_driver(driver: *driver) void = {
	driver.next = drivers_head;
	drivers_head = driver;
};

// Returns the driver associated with a filesystem.
export fn get_driver(name: str) (*driver | error) = {
	for (let cur = drivers_head; cur != null; cur = (cur: *driver).next) {
		const cur = cur: *driver;
		if (cur.name == name) {
			return cur;
		};
	};
	return errno::NODEV;
};

// Creates a filesystem from the given options.
export fn fs_open(opts: *fs_opts) (*superblock | error) = {
	assert(opts.fstype != "");
	const driver = get_driver(opts.fstype)?;
	return driver.impl.open(opts);
};
