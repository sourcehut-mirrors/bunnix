// See ext4_inode.h

use errors::{error, errno};

export @symbol("ext4_inode_get_mode") fn inode_get_mode(*sblock, nullable *inode) u32;
export @symbol("ext4_inode_set_mode") fn inode_set_mode(*sblock, nullable *inode, u32) void;
export @symbol("ext4_inode_get_uid") fn inode_get_uid(*inode) u32;
export @symbol("ext4_inode_set_uid") fn inode_set_uid(*inode, u32) void;
export @symbol("ext4_inode_get_gid") fn inode_get_gid(*inode) u32;
export @symbol("ext4_inode_set_gid") fn inode_set_gid(*inode, u32) void;
export @symbol("ext4_inode_get_size") fn inode_get_size(*sblock, *inode) u64;
export @symbol("ext4_inode_set_size") fn inode_set_size(*inode, u64) void;
export @symbol("ext4_inode_get_blocks_count") fn inode_get_blocks_count(*sblock, *inode) u64;
export @symbol("ext4_inode_set_blocks_count") fn inode_set_blocks_count(*sblock, *inode, u64) errno;
export @symbol("ext4_inode_get_dev") fn inode_get_dev(*inode) u32;
export @symbol("ext4_inode_set_dev") fn inode_set_dev(*inode, u32) void;

//uint32_t ext4_inode_get_access_time(struct ext4_inode *inode);
//void ext4_inode_set_access_time(struct ext4_inode *inode, uint32_t time);
//uint32_t ext4_inode_get_change_inode_time(struct ext4_inode *inode);
//void ext4_inode_set_change_inode_time(struct ext4_inode *inode, uint32_t time);
//uint32_t ext4_inode_get_modif_time(struct ext4_inode *inode);
//void ext4_inode_set_modif_time(struct ext4_inode *inode, uint32_t time);
//uint32_t ext4_inode_get_del_time(struct ext4_inode *inode);
//void ext4_inode_set_del_time(struct ext4_inode *inode, uint32_t time);
//uint16_t ext4_inode_get_links_cnt(struct ext4_inode *inode);
//void ext4_inode_set_links_cnt(struct ext4_inode *inode, uint16_t cnt);
//uint32_t ext4_inode_get_flags(struct ext4_inode *inode);
//void ext4_inode_set_flags(struct ext4_inode *inode, uint32_t flags);
//uint32_t ext4_inode_get_generation(struct ext4_inode *inode);
//void ext4_inode_set_generation(struct ext4_inode *inode, uint32_t gen);
//uint16_t ext4_inode_get_extra_isize(struct ext4_sblock *sb, struct ext4_inode *inode);
//void ext4_inode_set_extra_isize(struct ext4_sblock *sb, struct ext4_inode *inode, uint16_t size);
//uint64_t ext4_inode_get_file_acl(struct ext4_inode *inode, struct ext4_sblock *sb);
//void ext4_inode_set_file_acl(struct ext4_inode *inode, struct ext4_sblock *sb, uint64_t acl);
//uint32_t ext4_inode_get_direct_block(struct ext4_inode *inode, uint32_t idx);
//void ext4_inode_set_direct_block(struct ext4_inode *inode, uint32_t idx, uint32_t block);
//uint32_t ext4_inode_get_indirect_block(struct ext4_inode *inode, uint32_t idx);
//void ext4_inode_set_indirect_block(struct ext4_inode *inode, uint32_t idx, uint32_t block);
//uint32_t ext4_inode_type(struct ext4_sblock *sb, struct ext4_inode *inode);
//bool ext4_inode_is_type(struct ext4_sblock *sb, struct ext4_inode *inode, uint32_t type);
//bool ext4_inode_has_flag(struct ext4_inode *inode, uint32_t f);
//void ext4_inode_clear_flag(struct ext4_inode *inode, uint32_t f);
//void ext4_inode_set_flag(struct ext4_inode *inode, uint32_t f);
//uint32_t ext4_inode_get_csum(struct ext4_sblock *sb, struct ext4_inode *inode);
//void ext4_inode_set_csum(struct ext4_sblock *sb, struct ext4_inode *inode, uint32_t checksum);
//bool ext4_inode_can_truncate(struct ext4_sblock *sb, struct ext4_inode *inode);
//struct ext4_extent_header *ext4_inode_get_extent_header(struct ext4_inode *inode);
