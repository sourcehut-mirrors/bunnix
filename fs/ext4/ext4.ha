use dev::block;
use errors::{error, errno};
use fs;
use lib::lwext4;
use log;
use strings;

const EXT4: str = "ext4";

export type superblock = struct {
	fs::superblock,
	bdev: *block::blockdev,
	mp: lwext4::mountpoint,
};

// Opens a block device as an ext4 filesystem.
export fn open(bdev: *block::blockdev) (*fs::superblock | error) = {
	log::kprintfln(EXT4, "Opening ext4 filesystem from {}", block::name(bdev));

	// TODO:
	// - Verify block dev not in use by another filesystem
	// - Clean up on error
	// - Refactor lwext4 to use an external block cache
	let sb = alloc(superblock {
		impl = &ext4_impl,
		bdev = bdev,

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

	r = lwext4::fs_init(fs, lwbdev, true);
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

	return sb;
};

const ext4_impl = fs::superblock_iface {
	get_root = &ext4_get_root,
};

fn ext4_get_root(sb: *fs::superblock) *fs::inode = {
	const sb = sb: *superblock;
	return get_inode(sb, lwext4::EXT4_INODE_ROOT_INDEX)!;
};
