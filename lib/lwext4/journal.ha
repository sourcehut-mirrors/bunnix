// See ext4_journal.h

use types::c;

export type jbd_fs = struct {
	bdev: nullable *blockdev,
	inode_ref: inode_ref,
	sb: jbd_sb,
	dirty: bool,
};

export type jbd_buf = struct {
	jbd_lba: u32,
	block: block,
	trans: nullable *jbd_trans,
	block_rec: nullable *jbd_block_rec,
	buf_node: tailq_entry,
	dirty_buf_node: tailq_entry,
};

export type jbd_revoke_rec = struct {
	lba: u64,
	revoke_node: rb_entry,
};

export type jbd_block_rec = struct {
	lba: u64,
	trans: nullable *jbd_trans,
	block_rec_node: rb_entry,
	tbrec_node: list_entry,
	dirty_buf_queue: tailq_head,
};

export type jbd_trans = struct {
	trans_id: u32,
	start_iblock: u32,
	alloc_blocks: int,
	data_cnt: int,
	data_csum: u32,
	written_cnt: int,
	error: int,
	journal: nullable *jbd_journal,
	buf_queue: tailq_head,
	revoke_root: rb_head,
	tbrec_list: list_head,
	trans_node: tailq_entry,
};

export type jbd_journal = struct {
	first: u32,
	start: u32,
	last: u32,
	trans_id: u32,
	alloc_trans_id: u32,
	block_size: u32,
	cp_queue: tailq_head,
	block_rec_root: rb_head,
	jbd_fs: nullable *jbd_fs,
};
