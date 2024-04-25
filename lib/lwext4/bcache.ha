// See ext4_bcache.h

use errors::{error, errno};

export type buf = opaque;

export type block = struct {
	lb_id: u64,
	buf: nullable *buf,
	data: nullable *u8,
};

export type bcache = struct {
	cnt: u32,
	itemsize: u32,
	lru_ctr: u32,
	ref_blocks: u32,
	max_ref_blocks: u32,
	bdev: nullable *blockdev,
	dont_shake: bool,

	lba_root: struct {
		rbh_root: nullable *buf,
	},
	lru_root: struct {
		rbh_root: nullable *buf,
	},
	dirty_list: struct {
		slh_first: nullable *buf,
	},
};

export @symbol("ext4_bcache_init_dynamic") fn bcache_init_dynamic(*bcache, u32, u32) errno;
export @symbol("ext4_bcache_cleanup") fn bcache_cleanup(*bcache) void;
export @symbol("ext4_bcache_fini_dynamic") fn bcache_fini_dynamic(*bcache) errno;
export @symbol("ext4_buf_lowest_lru") fn buf_lowest_lru(*bcache) nullable *buf;
export @symbol("ext4_bcache_drop_buf") fn bcache_drop_buf(*bcache, *buf) void;
export @symbol("ext4_bcache_invalidate_buf") fn bcache_invalidate_buf(*bcache, *buf) void;
export @symbol("ext4_bcache_invalidate_lba") fn bcache_invalidate_lba(*bcache, u64, u32) void;
export @symbol("ext4_bcache_find_get") fn bcache_find_get(*bcache, *block, u64) nullable *buf;
export @symbol("ext4_bcache_alloc") fn bcache_alloc(*bcache, *block, bool) errno;
export @symbol("ext4_bcache_free") fn bcache_free(*bcache, *block) errno;
export @symbol("ext4_bcache_is_full") fn bcache_is_full(*bcache) bool;
