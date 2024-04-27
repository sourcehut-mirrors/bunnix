use errors::{error, errno};

// Generic file data structure, generally embedded in a filesystem-specific
// structure.
export type file = struct {
	impl: *file_iface,
	inode: *inode,
};

// Indicates an end-of-file condition.
export type EOF = done;

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
	read: nullable *fn_file_read,
	write: nullable *fn_file_write,
	seek: nullable *fn_file_seek,
	readdir: nullable *fn_file_readdir,
};

// Performs a read on a [[file]]. The provided buffer is not checked for
// validity within the current address space by the implementation.
export fn file_read(file: *file, buf: []u8) (size | EOF | error) = {
	match (file.impl.read) {
	case let func: *fn_file_read =>
		return func(file, buf);
	case null =>
		return errno::NOTSUP: error;
	};
};

// Performs a write on a [[file]]. The provided buffer is not checked for
// validity within the current address space by the implementation.
export fn file_write(file: *file, buf: []u8) (size | error) = {
	match (file.impl.write) {
	case let func: *fn_file_write =>
		return func(file, buf);
	case null =>
		return errno::NOTSUP: error;
	};
};

// Seeks a file to the requested offset, returning the new offset.
export fn file_seek(file: *file, offs: i64, w: whence) (size | error) = {
	match (file.impl.seek) {
	case let func: *fn_file_seek =>
		return func(file, offs, w);
	case null =>
		return errno::NOTSUP: error;
	};
};

// Reads the next directory from a file descriptor.
export fn file_readdir(file: *file, dent: *dirent) (void | EOF | error) = {
	match (file.impl.readdir) {
	case let func: *fn_file_readdir =>
		return func(file, dent);
	case null =>
		return errno::NOTSUP;
	};
};
