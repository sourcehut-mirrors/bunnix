use fs;
use errors::{error, errno};

let driver_impl = fs::driver_iface {
	open = &open,
};

let driver = fs::driver {
	name = "memfs",
	impl = &driver_impl,
	...
};

@init fn init() void = {
	fs::register_driver(&driver);
};

// Creates a new memory filesystem.
fn open(opts: *fs::fs_opts) (*fs::superblock | error) = {
	if (opts.readonly) {
		return errno::INVAL;
	};
	return new();
};
