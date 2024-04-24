use errors::{errno};
use types::c;

// See ext4.h

export type mountpoint = opaque;

export type file = struct {
	mp: nullable *mountpoint,
	inode: u32,
	flags: u32,
	fsize: u64,
	fpos: u64,
};

export type direntry = struct {
	inode: u32,
	entry_length: u16,
	name_length: u8,
	inode_type: u8,
	name: [255]u8,
};

export type dir = struct {
	f: *file,
	de: direntry,
	next_off: u64,
};

export @symbol("ext4_device_register") fn device_register(*blockdev, const *c::char) errno;
export @symbol("ext4_device_unregister") fn device_unregister(const *c::char) errno;
export @symbol("ext4_device_unregister_all") fn device_unregister_all() errno;
export @symbol("ext4_mount") fn mount(const *c::char, const *c::char, bool) errno;
export @symbol("ext4_unmount") fn unmount(const *c::char) errno;
export @symbol("ext4_journal_start") fn journal_start(const *c::char) errno;
export @symbol("ext4_journal_stop") fn journal_stop(const *c::char) errno;
export @symbol("ext4_recover") fn recover(const *c::char) errno;

export type mount_stats = struct {
	inodes_count: u32,
	free_inodes_count: u32,
	blocks_count: u64,
	free_blocks_count: u64,

	block_size: u32,
	block_group_count: u32,
	blocks_per_group: u32,
	inodes_per_group: u32,

	volume_name: [16]c::char,
};

export @symbol("ext4_mount_point_stats") fn mount_point_stats(const *c::char, *mount_stats) errno;
// ...
export @symbol("ext4_fremove") fn fremove(const *c::char) errno;
export @symbol("ext4_flink") fn flink(const *c::char, const *c::char) errno;
export @symbol("ext4_frename") fn frename(const *c::char, const *c::char) errno;
export @symbol("ext4_fopen") fn fopen(*file, const *c::char, const *c::char) errno;
export @symbol("ext4_fopen2") fn fopen2(*file, const *c::char, int) errno;
export @symbol("ext4_fclose") fn fclose(*file) errno;
export @symbol("ext4_ftruncate") fn ftruncate(*file, u64) errno;
export @symbol("ext4_fread") fn fread(*file, *opaque, size, *size) errno;
export @symbol("ext4_fwrite") fn fwrite(*file, const *opaque, size, *size) errno;
export @symbol("ext4_fseek") fn fseek(*file, i64, u32) errno;
export @symbol("ext4_ftell") fn ftell(*file) errno;
export @symbol("ext4_fsize") fn fsize(*file) u64;
// ...
export @symbol("ext4_mode_set") fn mode_set(const *c::char, u32) errno;
export @symbol("ext4_mode_get") fn mode_get(const *c::char, u32) errno;
export @symbol("ext4_owner_set") fn owner_set(const *c::char, u32, u32) errno;
export @symbol("ext4_owner_get") fn owner_get(const *c::char, *u32, *u32) errno;
export @symbol("ext4_atime_set") fn atime_set(const *c::char, u32) errno;
export @symbol("ext4_mtime_set") fn mtime_set(const *c::char, u32) errno;
export @symbol("ext4_ctime_set") fn ctime_set(const *c::char, u32) errno;
export @symbol("ext4_atime_get") fn atime_get(const *c::char, *u32) errno;
export @symbol("ext4_mtime_get") fn mtime_get(const *c::char, *u32) errno;
export @symbol("ext4_ctime_get") fn ctime_get(const *c::char, *u32) errno;
export @symbol("ext4_fsymlink") fn fsymlink(const *c::char, const *c::char) errno;
export @symbol("ext4_mknod") fn mknod(const *c::char, int, u32) errno;
export @symbol("ext4_readlink") fn readlink(const *c::char, *c::char, size, *size) errno;
// ...
export @symbol("ext4_dir_mk") fn dir_mk(const *c::char) errno;
export @symbol("ext4_dir_open") fn dir_open(*dir, const *c::char) errno;
export @symbol("ext4_dir_close") fn dir_close(*dir) errno;
export @symbol("ext4_dir_entry_next") fn dir_entry_next(*dir) const *direntry;
export @symbol("ext4_dir_entry_rewind") fn dir_entry_rewind(*dir) void;
