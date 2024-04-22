use errors::{error, errno};

// Generic inode data structure, generally embedded in a filesystem-specific
// structure.
export type inode = struct {
	impl: const *inode_iface,
	sb: const *superblock,
	ino: uint,
	dev: (uint, uint),
	mode: mode,
	uid: uint,
	gid: uint,
	blocks: size,
	bytes: size,
};

// Opens an inode file.
export type fn_inode_open = fn(ino: *inode) (*file | error);

// Adds an inode as a child of this inode.
export type fn_inode_link = fn(ino: *inode, child: *inode, name: str) (void | error);

// Removes a child of this inode.
export type fn_inode_unlink = fn(ino: *inode, name: str) (void | error);

// Creates a new file as a child of this inode.
export type fn_inode_create = fn(ino: *inode, name: str, mode: uint) (*inode | error);

// Makes a new directory in this inode.
export type fn_inode_mkdir = fn(ino: *inode, name: str, mode: uint) (*inode | error);

// Removes a directory from this inode.
export type fn_inode_rmdir = fn(ino: *inode, name: str) (void | error);

// inode implementation.
export type inode_iface = struct {
	open: nullable *fn_inode_open,
	link: nullable *fn_inode_link,
	unlink: nullable *fn_inode_unlink,
	create: nullable *fn_inode_create,
	mkdir: nullable *fn_inode_mkdir,
	rmdir: nullable *fn_inode_rmdir,
};
