use errors::{errno};

// See ext4_blockdev.h

export type blockdev_iface = struct {
	open: *fn(bdev: *blockdev) errno,
	bread: *fn(bdev: *blockdev, buf: *opaque, blk_id: u64, blk_cnt: u32) errno,
	bwrite: *fn(bdev: *blockdev, buf: const *opaque, blk_id: u64, blk_cnt: u32) errno,
	close: *fn(bdev: *blockdev) errno,
	lock: nullable *fn(bdev: *blockdev) errno,
	unlock: nullable *fn(bdev: *blockdev) errno,
	ph_bsize: u32,
	ph_bcnt: u64,
	ph_bbuf: nullable *u8,
	ph_refctr: u32,
	bread_ctr: u32,
	bwrite_ctr: u32,
	p_user: nullable *opaque,
};

export type blockdev = struct {
	bdif: *blockdev_iface,
	part_offset: u64,
	part_size: u64,
	bc: nullable *bcache,
	lg_bsize: u32,
	lg_bcnt: u64,
	cache_write_back: u32,
	fs: nullable *fs,
	journal: nullable *opaque,
};

export @symbol("ext4_block_init") fn block_init(*blockdev) errno;
export @symbol("ext4_block_bind_bcache") fn block_bind_bcache(*blockdev, *bcache) errno;
// ...
export @symbol("ext4_block_set_lb_size") fn block_set_lb_size(*blockdev, u32) void;
