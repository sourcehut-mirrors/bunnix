use dev::block;
use errors::{error, errno};
use fs;
use io;
use lib::lwext4;
use log;
use strings;

const EXT4: str = "ext4";

export type superblock = struct {
	fs::superblock,
	bdev: *block::blockdev,
	mp: lwext4::mountpoint,
	ic: fs::icache,
};

let driver_impl = fs::driver_iface {
	open = &open,
};

let driver = fs::driver {
	name = "ext4",
	impl = &driver_impl,
	...
};

@init fn init() void = {
	fs::register_driver(&driver);
};

// Opens a block device as an ext4 filesystem.
fn open(opts: *fs::fs_opts) (*fs::superblock | error) = {
	const bdev = match (opts.device) {
	case let dev: *block::blockdev =>
		yield dev;
	case null =>
		log::kprintfln(EXT4, "Attempted to open ext4 filesystem from null device");
		return errno::INVAL: error;
	};

	// TODO:
	// - Verify block dev not in use by another filesystem
	// - Clean up on error
	// - Refactor lwext4 to use an external block cache
	let sb = alloc(superblock {
		impl = &ext4_impl,
		bdev = bdev,
		ic = fs::icache { ... },

		// We use a synthetic "mountpoint" to please some lwext4
		// opeartions, like ext4_fread, but we generally try to avoid
		// the lwext4 mountpoint abstraction because it is bad
		mp = lwext4::mountpoint {
			mounted = true,
			...
		},
	});

	const lwbdev = lwext4::mkblockdev(bdev);
	let r = lwext4::block_init(lwbdev);
	if (r != errno::NONE) {
		return r: error;
	};

	let fs = &sb.mp.fs;
	let bc = &sb.mp.bc;

	r = lwext4::fs_init(fs, lwbdev, opts.readonly);
	if (r != errno::NONE) {
		return r: error;
	};

	// TODO: import time::chrono and date stuff
	const last_mount = fs.sb.mount_time;
	if (last_mount != 0) {
		log::kprintfln(EXT4, "Last mounted at {}", last_mount);
	};

	const bsize = lwext4::sb_get_block_size(&fs.sb);
	lwext4::block_set_lb_size(lwbdev, bsize);

	r = lwext4::bcache_init_dynamic(bc, 16, bsize);
	if (r != errno::NONE) {
		return r: error;
	};
	if (bc.itemsize != bsize) {
		return errno::NOTSUP: error;
	};

	r = lwext4::block_bind_bcache(lwbdev, bc);
	if (r != errno::NONE) {
		return r: error;
	};

	lwbdev.fs = fs;
	return sb;
};

const ext4_impl = fs::superblock_iface {
	get_root = &ext4_get_root,
};

fn ext4_get_root(sb: *fs::superblock) *io::inode = {
	const sb = sb: *superblock;
	return get_inode(sb, lwext4::EXT4_INODE_ROOT_INDEX)!;
};

fn flush(sb: *superblock) (void | error) = {
	// TODO: Should we only do this periodically?
	log::kprintln(EXT4, "Flush filesystem to disk");
	let r = lwext4::block_cache_flush(sb.mp.fs.bdev);
	if (r != errno::NONE) {
		return r;
	};
};
