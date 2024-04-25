// XXX: This type is lwext4-internal
// We use it to create synthetic ext4_files with a nonsense mountpoint to take
// advantage of some abstractions to ease file operations without using the ext4
// mountpoint abstraction

use types::c;

export type mountpoint = struct {
	mounted: bool,
	name: [33]c::char,
	os_locks: nullable *lock,
	fs: fs,
	jbd_fs: jbd_fs,
	jbd_journal: jbd_journal,
	bc: bcache,
};
