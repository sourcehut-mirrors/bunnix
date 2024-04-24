// See ext4_fs.h

use errors::{errno, error};

export type jbd_fs = opaque;
export type jbd_journal = opaque;
export type jbd_trans = opaque;

export type fs = struct {
	read_only: bool,

	bdev: nullable *blockdev,
	sb: sblock,

	inode_block_limits: [4]u64,
	inode_blocks_per_level: [4]u64,

	last_inode_bg_id: u32,

	jbd_fs: nullable *jbd_fs,
	jbd_journal: nullable *jbd_journal,
	curr_trans: nullable *jbd_trans,
};

export type block_group = opaque;

export type block_group_ref = struct {
	block: block,
	group: nullable *block_group,
	fs: nullable *fs,
	index: u32,
	dirty: bool,
};

export type inode_ref = struct {
	block: block,
	inode: nullable *inode,
	fs: nullable *fs,
	index: u32,
	dirty: bool,
};

export @symbol("ext4_fs_init") fn fs_init(*fs, *blockdev, bool) errno;
export @symbol("ext4_fs_fini") fn fs_fini(*fs) errno;
export @symbol("ext4_fs_get_inode_ref") fn fs_get_inode_ref(*fs, u32, *inode_ref) errno;
