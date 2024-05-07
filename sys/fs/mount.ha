use errors::{error, errno};
use io;
use path;
use strings;

export type vfs = struct {
	root: nullable *io::inode,
};

// A mountpoint in a virtual filesystem.
export type mountpoint = struct {
	sb: const *superblock,
};

// Mounts the root filesystem and return the root inode.
export fn mount_root(
	vfs: *vfs,
	fs: const *superblock,
) *io::inode = {
	assert(vfs.root == null);
	let root = superblock_get_root(fs);
	vfs.root = root;
	root.mountpoint = alloc(mountpoint {
		sb = fs,
	});
	return root;
};

// Mounts a filesystem at the given path.
export fn mount_fs(
	root: *io::inode,
	fs: const *superblock,
	path: str,
) (void | error) = {
	const (parent, _) = walk(root, path)?;
	if (parent.mountpoint != null) {
		return errno::BUSY;
	};
	parent.mountpoint = alloc(mountpoint {
		sb = fs,
	});
};
