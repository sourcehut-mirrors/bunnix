// See ext4_types.h

use types::c;

export def EXT4_CHECKSUM_CRC32C: uint = 1;
export def UUID_SIZE: uint = 16;

export type sblock = struct @packed {
	inodes_count: u32,
	blocks_count_lo: u32,

	reserved_blocks_count_lo: u32,
	free_blocks_count_lo: u32,
	free_inodes_count: u32,
	first_data_block: u32,
	log_block_size: u32,
	log_cluster_size: u32,
	blocks_per_group: u32,
	frags_per_group: u32,
	inodes_per_group: u32,
	mount_time: u32,
	write_time: u32,
	mount_count: u16,
	max_mount_count: u16,
	magic: u16,
	state: u16,
	errors: u16,
	minor_rev_level: u16,
	last_check_time: u32,
	check_interval: u32,
	creator_os: u32,
	rev_level: u32,
	def_resuid: u16,
	def_resgid: u16,

	first_inode: u32,
	inode_size: u16,
	block_group_index: u16,
	features_compatible: u32,
	features_incompatible: u32,
	features_read_only: u32,
	uuid: [UUID_SIZE]u8,
	volume_name: [16]c::char,
	last_mounted: [64]c::char,
	algorithm_usage_bitmap: u32,

	s_prealloc_blocks: u8,
	s_prealloc_dir_blocks: u8,
	s_reserved_gdt_blocks: u16,

	journal_uuid: [UUID_SIZE]u8,
	journal_inode_number: u32,
	journal_dev: u32,
	last_orphan: u32,
	hash_seed: [4]u32,
	default_hash_version: u8,
	journal_backup_type: u8,
	desc_size: u16,
	default_mount_opts: u32,
	first_meta_bg: u32,
	mkfs_time: u32,
	journal_blocks: [17]u32,

	blocks_count_hi: u32,
	reserved_blocks_count_hi: u32,
	free_blocks_count_hi: u32,
	min_extra_isize: u16,
	want_extra_isize: u16,
	flags: u32,
	raid_stride: u16,
	mmp_interval: u16,
	mmp_block: u64,
	raid_stripe_width: u32,
	log_groups_per_flex: u8,
	checksum_type: u8,
	reserved_pad: u16,
	kbytes_written: u64,
	snapshot_inum: u32,
	snapshot_id: u32,
	snapshot_r_blocks_count: u64,
	snapshot_list: u32,
	error_count: u32,
	first_error_time: u32,
	first_error_ino: u32,
	first_error_block: u64,
	first_error_func: [32]u8,
	first_error_line: u32,
	last_error_time: u32,
	last_error_ino: u32,
	last_error_line: u32,
	last_error_block: u64,
	last_error_func: [32]u8,
	mount_opts: [64]u8,
	usr_quota_inum: u32,
	grp_quota_inum: u32,
	overhead_clusters: u32,
	backup_bgs: [2]u32,
	encrypt_algos: [4]u8 ,
	encrypt_pw_salt: [16]u8 ,
	lpf_ino: u32,
	padding: [100]u32,
	checksum: u32,
};


export def EXT4_MIN_BLOCK_GROUP_DESCRIPTOR_SIZE: uint = 32;
export def EXT4_MAX_BLOCK_GROUP_DESCRIPTOR_SIZE: uint = 64;

export def EXT4_MIN_BLOCK_SIZE: uint = 1024;
export def EXT4_MAX_BLOCK_SIZE: uint = 65536;
export def EXT4_REV0_INODE_SIZE: uint = 128;

export def EXT4_INODE_BLOCK_SIZE: uint = 512;

export def EXT4_INODE_DIRECT_BLOCK_COUNT: uint = 12;
export def EXT4_INODE_INDIRECT_BLOCK: uint = EXT4_INODE_DIRECT_BLOCK_COUNT;
export def EXT4_INODE_DOUBLE_INDIRECT_BLOCK: uint = EXT4_INODE_INDIRECT_BLOCK + 1;
export def EXT4_INODE_TRIPPLE_INDIRECT_BLOCK: uint = EXT4_INODE_DOUBLE_INDIRECT_BLOCK + 1;
export def EXT4_INODE_BLOCKS: uint = EXT4_INODE_TRIPPLE_INDIRECT_BLOCK + 1;
export def EXT4_INODE_INDIRECT_BLOCK_COUNT: uint = EXT4_INODE_BLOCKS - EXT4_INODE_DIRECT_BLOCK_COUNT;

export type inode = struct @packed {
	mode: u16,
	uid: u16,
	size_lo: u32,
	access_time: u32,
	change_inode_time: u32,
	modification_time: u32,
	deletion_time: u32,
	gid: u16,
	links_count: u16,
	blocks_count_lo: u32,
	flags: u32,
	unused_osd1: u32,
	blocks: [EXT4_INODE_BLOCKS]u32,
	generation: u32,
	file_acl_lo: u32,
	size_hi: u32,
	obso_faddr: u32,

	osd2: union {
		linux2: struct {
			blocks_high: u16,
			file_acl_high: u16,
			uid_high: u16,
			gid_high: u16,
			checksum_lo: u16,
			reserved2: u16,
		},

		hurd2: struct {
			reserved1: u16,
			mode_high: u16,
			uid_high: u16,
			gid_high: u16,
			author: u32,
		},
	},

	extra_isize: u16,
	checksum_hi: u16,
	ctime_extra: u32,
	mtime_extra: u32,
	atime_extra: u32,
	crtime: u32,
	crtime_extra: u32,
	version_hi: u32,
};

export def EXT4_INODE_MODE_FIFO: uint = 0x1000;
export def EXT4_INODE_MODE_CHARDEV: uint = 0x2000;
export def EXT4_INODE_MODE_DIRECTORY: uint = 0x4000;
export def EXT4_INODE_MODE_BLOCKDEV: uint = 0x6000;
export def EXT4_INODE_MODE_FILE: uint = 0x8000;
export def EXT4_INODE_MODE_SOFTLINK: uint = 0xA000;
export def EXT4_INODE_MODE_SOCKET: uint = 0xC000;
export def EXT4_INODE_MODE_TYPE_MASK: uint = 0xF000;

export def EXT4_INODE_FLAG_SECRM: uint = 0x00000001;
export def EXT4_INODE_FLAG_UNRM: uint = 0x00000002;
export def EXT4_INODE_FLAG_COMPR: uint = 0x00000004;
export def EXT4_INODE_FLAG_SYNC: uint = 0x00000008;
export def EXT4_INODE_FLAG_IMMUTABLE: uint = 0x00000010;
export def EXT4_INODE_FLAG_APPEND: uint = 0x00000020;
export def EXT4_INODE_FLAG_NODUMP: uint = 0x00000040;
export def EXT4_INODE_FLAG_NOATIME: uint = 0x00000080;

export def EXT4_INODE_FLAG_DIRTY: uint = 0x00000100;
export def EXT4_INODE_FLAG_COMPRBLK: uint = 0x00000200;
export def EXT4_INODE_FLAG_NOCOMPR: uint = 0x00000400;
export def EXT4_INODE_FLAG_ECOMPR: uint = 0x00000800;

export def EXT4_INODE_FLAG_INDEX: uint = 0x00001000;
export def EXT4_INODE_FLAG_IMAGIC: uint = 0x00002000;
export def EXT4_INODE_FLAG_JOURNAL_DATA: uint = 0x00004000;
export def EXT4_INODE_FLAG_NOTAIL: uint = 0x00008000;
export def EXT4_INODE_FLAG_DIRSYNC: uint = 0x00010000;
export def EXT4_INODE_FLAG_TOPDIR: uint = 0x00020000;
export def EXT4_INODE_FLAG_HUGE_FILE: uint = 0x00040000;
export def EXT4_INODE_FLAG_EXTENTS: uint = 0x00080000;
export def EXT4_INODE_FLAG_EA_INODE: uint = 0x00200000;
export def EXT4_INODE_FLAG_EOFBLOCKS: uint = 0x00400000;
export def EXT4_INODE_FLAG_RESERVED: uint = 0x80000000;

export def EXT4_INODE_ROOT_INDEX: uint = 2;

export def EXT4_DIRECTORY_FILENAME_LEN: uint = 255;

export def EXT4_DE_UNKNOWN: u8 = 0;
export def EXT4_DE_REG_FILE: u8 = 1;
export def EXT4_DE_DIR: u8 = 2;
export def EXT4_DE_CHRDEV: u8 = 3;
export def EXT4_DE_BLKDEV: u8 = 4;
export def EXT4_DE_FIFO: u8 = 5;
export def EXT4_DE_SOCK: u8 = 6;
export def EXT4_DE_SYMLIN: u8 = 7;

export type dir_en_internal = union {
	name_length_high: u8,
	inode_type: u8,
};

export type dir_en = struct {
	inode: u32,
	entry_len: u16,
	name_len: u8,

	in: dir_en_internal,
	name: [*]c::char,
};
