use errors::{error, errno};

// Generic inode data structure, generally embedded in a filesystem-specific
// structure.
export type inode = struct {
	impl: const *inode_iface,
	ino: uint,
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

// Makes a new directory in this inode.
export type fn_inode_mkdir = fn(ino: *inode, name: str, mode: mode) (*inode | error);

// Removes a directory from this inode.
export type fn_inode_rmdir = fn(ino: *inode, name: str) (void | error);

// inode implementation.
export type inode_iface = struct {
	open: nullable *fn_inode_open,
	lookup: nullable *fn_inode_lookup,
	link: nullable *fn_inode_link,
	unlink: nullable *fn_inode_unlink,
	create: nullable *fn_inode_create,
	mkdir: nullable *fn_inode_mkdir,
	rmdir: nullable *fn_inode_rmdir,
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

// Creates a new file as a child of this inode.
export fn inode_create(ino: *inode, name: str, mode: mode) (*inode | error) = {
	match (ino.impl.create) {
	case let func: *fn_inode_create =>
		return func(ino, name, mode);
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
