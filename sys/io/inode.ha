use errors::{error, errno};

// Generic inode data structure, generally embedded in a filesystem-specific
// structure.
export type inode = struct {
	impl: const *inode_iface,

	// Note the reference count is zero when one reference is held
	refs: uint,

	// See fs::mountpoint
	mountpoint: nullable *opaque,

	ino: u32,
	dev: u64,
	rdev: u64,
	mode: mode,
	uid: uint,
	gid: uint,
	blocks: size,
	bytes: size,
	// TODO: Add times
};

// Opens an inode file.
export type fn_inode_open = fn(ino: *inode) (*file | error);

// Looks up a child of this inode.
export type fn_inode_lookup = fn(ino: *inode, name: str) (*inode | error);

// Adds an inode as a child of this inode.
export type fn_inode_link = fn(ino: *inode, child: *inode, name: str) (void | error);

// Removes a child of this inode.
export type fn_inode_unlink = fn(ino: *inode, name: str) (void | error);

// Creates a new file as a child of this inode.
export type fn_inode_create = fn(ino: *inode, name: str, mode: mode) (*inode | error);

// Truncate this inode.
export type fn_inode_trunc = fn(ino: *inode, length: size) (void | error);

// Makes a new directory in this inode.
export type fn_inode_mkdir = fn(ino: *inode, name: str, mode: mode) (*inode | error);

// Removes a directory from this inode.
export type fn_inode_rmdir = fn(ino: *inode, name: str) (void | error);

// Makes a special file in this inode.
export type fn_inode_mknod = fn(
	ino: *inode,
	name: str,
	mode: mode,
	dev: u64,
) (*inode | error);

// Called when the last reference to this inode is dropped, freeing resources
// associated with it.
export type fn_inode_finish = fn(ino: *inode) void;

// inode implementation.
export type inode_iface = struct {
	open: nullable *fn_inode_open,
	lookup: nullable *fn_inode_lookup,
	link: nullable *fn_inode_link,
	unlink: nullable *fn_inode_unlink,
	create: nullable *fn_inode_create,
	trunc: nullable *fn_inode_trunc,
	mkdir: nullable *fn_inode_mkdir,
	rmdir: nullable *fn_inode_rmdir,
	mknod: nullable *fn_inode_mknod,
	finish: nullable *fn_inode_finish,
};

// Opens an inode as a file.
export fn inode_open(ino: *inode) (*file | error) = {
	match (ino.impl.open) {
	case let func: *fn_inode_open =>
		return func(ino);
	case null =>
		return errno::NOTSUP;
	};
};

// Looks up a child of this inode.
export fn inode_lookup(ino: *inode, name: str) (*inode | error) = {
	match (ino.impl.lookup) {
	case let func: *fn_inode_lookup =>
		return func(ino, name);
	case null =>
		return errno::NOTSUP;
	};
};

// Creates a hard link
export fn inode_link(ino: *inode, child: *inode, name: str) (void | error) = {
	match (ino.impl.link) {
	case let func: *fn_inode_link =>
		return func(ino, child, name);
	case null =>
		return errno::NOTSUP;
	};
};

// Removes a file
export fn inode_unlink(ino: *inode, name: str) (void | error) = {
	if (ino.mountpoint != null) {
		return errno::BUSY;
	};

	match (ino.impl.unlink) {
	case let func: *fn_inode_unlink =>
		return func(ino, name);
	case null =>
		return errno::NOTSUP;
	};
};

// Creates a new file as a child of this inode.
export fn inode_create(ino: *inode, name: str, mode: mode) (*inode | error) = {
	match (ino.impl.create) {
	case let func: *fn_inode_create =>
		return func(ino, name, mode);
	case null =>
		return errno::NOTSUP;
	};
};

// Truncates this inode.
export fn inode_trunc(ino: *inode, length: size) (void | error) = {
	match (ino.impl.trunc) {
	case let func: *fn_inode_trunc =>
		return func(ino, length);
	case null =>
		return errno::NOTSUP;
	};
};

// Makes a new directory in this inode.
export fn inode_mkdir(ino: *inode, name: str, mode: mode) (*inode | error) = {
	match (ino.impl.mkdir) {
	case let func: *fn_inode_mkdir =>
		return func(ino, name, mode);
	case null =>
		return errno::NOTSUP;
	};
};

// Makes a special file in this inode.
export fn inode_mknod(
	ino: *inode,
	name: str,
	mode: mode,
	rdev: u64,
) (*inode | error) = {
	match (ino.impl.mknod) {
	case let func: *fn_inode_mknod =>
		return func(ino, name, mode, rdev);
	case null =>
		return errno::NOTSUP;
	};
};

// Increments the reference count of an inode.
export fn inode_ref(ino: *inode) void = {
	ino.refs += 1;
};

// Decrements the reference count of an inode, freeing it if it reaches zero.
export fn inode_unref(ino: *inode) void = {
	if (ino.refs == 0) {
		match (ino.impl.finish) {
		case let func: *fn_inode_finish =>
			assert(ino.mountpoint == null,
				"io::inode_unref freeing inode with active mount");
			func(ino);
		case null => void;
		};

		return;
	};

	ino.refs -= 1;
};
