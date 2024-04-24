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
	lwbdev: *lwext4::blockdev,
	lwfs: lwext4::fs,
};

// Opens a block device as an ext4 filesystem.
export fn open(bdev: *block::blockdev) (*fs::superblock | error) = {
	log::kprintfln(EXT4, "Opening filesystem from {}", block::name(bdev));

	// TODO: verify block dev not in use by another filesystem
	const lwbdev = lwext4::mkblockdev(bdev);
	let sb = alloc(superblock {
		impl = &ext4_impl,
		bdev = bdev,
		lwbdev = lwbdev,
		...
	});
	lwext4::dmask_set(~0);

	let r = lwext4::block_init(lwbdev);
	if (r != errno::NONE) {
		return r: error;
	};

	r = lwext4::fs_init(&sb.lwfs, lwbdev, true);
	if (r != errno::NONE) {
		return r: error;
	};

	// TODO: import time::chrono and date stuff
	const last_mount = sb.lwfs.sb.mount_time;
	log::kprintfln(EXT4, "Last mounted at {}", last_mount);

	abort();
};

const ext4_impl = fs::superblock_iface {
	get_root = &ext4_get_root,
};

fn ext4_get_root(sb: *fs::superblock) *fs::inode = {
	abort(); // TODO
};
