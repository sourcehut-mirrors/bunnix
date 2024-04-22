use errors::{error, errno};

// Generic file data structure, generally embedded in a filesystem-specific
// structure.
export type file = struct {
	inode: *inode,
	pos: size,
};

// Indicates an end-of-file condition.
export type EOF = void;

// From "whence" a seek operation should occur.
export type whence = enum {
	SET = 0, // Relative to beginning (i.e. set absolute position).
	CUR = 1, // Relative to current position.
	END = 2, // Relative to end of handle.
};

// Performs a read on a [[file]]. The provided buffer is not checked for
// validity within the current address space by the implementation.
export type fn_file_read = fn(fd: *file, buf: []u8) (size | EOF | error);

// Performs a write on a [[file]]. The provided buffer is not checked for
// validity within the current address space by the implementation.
export type fn_file_write = fn(fd: *file, buf: []u8) (size | error);

// Seeks a file to the requested offset, returning the new offset.
export type fn_file_seek = fn(fd: *file, offs: i64, w: whence) (size | error);

// Reads the next directory from a file descriptor.
export type fn_file_readdir = fn(fd: *file, dent: *dirent) (void | EOF | error);

// file implementation
export type file_iface = struct {
	read: *fn_file_read,
	write: *fn_file_write,
	seek: *fn_file_seek,
	readdir: *fn_file_readdir,
};
