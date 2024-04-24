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

export @symbol("ext4_device_register") fn device_register(bd: *blockdev, dev_name: const *c::char) errno;
export @symbol("ext4_device_unregister") fn device_unregister(dev_name: const *c::char) errno;
export @symbol("ext4_device_unregister_all") fn device_unregister_all() errno;
export @symbol("ext4_mount") fn mount(dev_name: const *c::char, mount_point: const *c::char, read_only: bool) errno;
export @symbol("ext4_unmount") fn unmount(mount_point: const *c::char) errno;
export @symbol("ext4_journal_start") fn journal_start(mount_point: const *c::char) errno;
export @symbol("ext4_journal_stop") fn journal_stop(mount_point: const *c::char) errno;
export @symbol("ext4_recover") fn recover(mount_point: const *c::char) errno;

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

export @symbol("ext4_mount_point_stats") fn mount_point_stats(mount_point: const *c::char, stats: *mount_stats) errno;
export @symbol("ext4_fopen") fn fopen(file: *file, path: const *c::char, flags: const *c::char) errno;
export @symbol("ext4_fopen2") fn fopen2(file: *file, path: const *c::char, flags: int) errno;
export @symbol("ext4_fclose") fn fclose(file: *file) errno;
export @symbol("ext4_ftruncate") fn ftruncate(file: *file, sz: u64) errno;
export @symbol("ext4_fread") fn fread(file: *file, buf: *opaque, sz: size, rcnt: *size) errno;
export @symbol("ext4_fwrite") fn fwrite(file: *file, buf: const *opaque, sz: size, wcnt: *size) errno;
