// See ext4_dir.h

use errors::{error, errno};
use types::c;

export type dir_iter = struct {
	inode_ref: nullable *inode_ref,
	curr_blk: block,
	curr_off: u64,
	curr: nullable *dir_en,
};

export type dir_search_result = struct {
	block: block,
	dentry: nullable *dir_en,
};

export fn dir_en_get_name_len(sb: *sblock, de: *dir_en) u16 = {
	let v = de.name_len;
	if (sb.rev_level == 0 && sb.minor_rev_level < 5) {
		v |= de.in.name_length_high << 8;
	};
	return v;
};

export @symbol("ext4_dir_iterator_init") fn dir_iterator_init(*dir_iter, *inode_ref, u64) errno;
export @symbol("ext4_dir_iterator_next") fn dir_iterator_next(*dir_iter) errno;
export @symbol("ext4_dir_iterator_fini") fn dir_iterator_fini(*dir_iter) errno;
export @symbol("ext4_dir_find_entry") fn dir_find_entry(*dir_search_result, *inode_ref, const *c::char, u32) errno;
export @symbol("ext4_dir_destroy_result") fn dir_destroy_result(*inode_ref, *dir_search_result) errno;
export @symbol("ext4_dir_add_entry") fn dir_add_entry(*inode_ref, const *c::char, u32, *inode_ref) errno;

//void ext4_dir_write_entry(struct ext4_sblock *sb, struct ext4_dir_en *en, uint16_t entry_len, struct ext4_inode_ref *child, const char *name, size_t name_len);
//int ext4_dir_find_entry(struct ext4_dir_search_result *result, struct ext4_inode_ref *parent, const char *name, uint32_t name_len);
//int ext4_dir_remove_entry(struct ext4_inode_ref *parent, const char *name, uint32_t name_len);
//int ext4_dir_try_insert_entry(struct ext4_sblock *sb, struct ext4_inode_ref *inode_ref, struct ext4_block *dst_blk, struct ext4_inode_ref *child, const char *name, uint32_t name_len);
//int ext4_dir_find_in_block(struct ext4_block *block, struct ext4_sblock *sb, size_t name_len, const char *name, struct ext4_dir_en **res_entry);
//int ext4_dir_destroy_result(struct ext4_inode_ref *parent, struct ext4_dir_search_result *result);
//void ext4_dir_set_csum(struct ext4_inode_ref *inode_ref, struct ext4_dir_en *dirent);
//void ext4_dir_init_entry_tail(struct ext4_dir_entry_tail *t);
