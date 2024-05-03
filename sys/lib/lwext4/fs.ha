// See ext4_fs.h

use errors::{errno, error};

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
export @symbol("ext4_fs_alloc_inode") fn fs_alloc_inode(*fs, *inode_ref, int) errno;
export @symbol("ext4_fs_inode_blocks_init") fn fs_inode_blocks_init(*fs, *inode_ref) void;
export @symbol("ext4_fs_put_inode_ref") fn fs_put_inode_ref(*inode_ref) errno;
export @symbol("ext4_fs_inode_links_count_inc") fn fs_inode_links_count_inc(*inode_ref) void;
export @symbol("ext4_fs_inode_links_count_dec") fn fs_inode_links_count_dec(*inode_ref) void;
export @symbol("ext4_fs_free_inode") fn fs_free_inode(*inode_ref) errno;
