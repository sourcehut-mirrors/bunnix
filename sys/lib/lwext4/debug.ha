export @symbol("ext4_dmask_set") fn dmask_set(m: u32) void;
export @symbol("ext4_dmask_clr") fn dmask_clr(m: u32) void;
export @symbol("ext4_dmask_get") fn dmask_get(m: u32) u32;

export def DEBUG_BALLOC: u32 = (1 << 0);
export def DEBUG_BCACHE: u32 = (1 << 1);
export def DEBUG_BITMAP: u32 = (1 << 2);
export def DEBUG_BLOCK_GROUP: u32 = (1 << 3);
export def DEBUG_BLOCKDEV: u32 = (1 << 4);
export def DEBUG_DIR_IDX: u32 = (1 << 5);
export def DEBUG_DIR: u32 = (1 << 6);
export def DEBUG_EXTENT: u32 = (1 << 7);
export def DEBUG_FS: u32 = (1 << 8);
export def DEBUG_HASH: u32 = (1 << 9);
export def DEBUG_IALLOC: u32 = (1 << 10);
export def DEBUG_INODE: u32 = (1 << 11);
export def DEBUG_SUPER: u32 = (1 << 12);
export def DEBUG_XATTR: u32 = (1 << 13);
export def DEBUG_MKFS: u32 = (1 << 14);
export def DEBUG_EXT4: u32 = (1 << 15);
export def DEBUG_JBD: u32 = (1 << 16);
export def DEBUG_MBR: u32 = (1 << 17);

export def DEBUG_NOPREFIX: u32 = (1 << 31);
export def DEBUG_ALL: u32 = (0xFFFFFFFF);
