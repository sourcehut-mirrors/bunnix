use errors::{error, errno};
use path;
use strings;

export type vfs = struct {
	mounts: []mountpoint,
};

// A mountpoint in a virtual filesystem.
export type mountpoint = struct {
	path: str,
	sb: const *superblock,
};

// Mounts the root filesystem.
export fn mount_root(
	vfs: *vfs,
	fs: const *superblock,
) void = {
	assert(len(vfs.mounts) == 0);
	append(vfs.mounts, mountpoint {
		path = strings::dup("/"),
		sb = fs,
	});
};

// Finds the mountpoint associated with the given path and trims off the leading
// path components.
export fn find_mountpoint(
	vfs: *vfs,
	iter: *path::iterator,
) (*mountpoint | error) = {
	const rem = path::iterrem(iter);
	assert(path::abs(rem));

	// TODO: make this better
	let mp: nullable *mountpoint = null;
	let max = 0z;
	for (let mnt &.. vfs.mounts) {
		if (!strings::hasprefix(rem, mnt.path)) {
			continue;
		};
		if (len(mnt.path) <= max) {
			continue;
		};
		mp = mnt;
		max = len(mnt.path);
	};

	const mp = match (mp) {
	case null =>
		return errno::NOENT;
	case let mp: *mountpoint =>
		yield mp;
	};

	// Trim iterator
	let mpath = path::init(mp.path)!;
	let miter = path::iter(&mpath);
	for (let x => path::nextiter(&miter)) {
		path::nextiter(iter);
	};
	return mp;
};
