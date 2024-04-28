// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};

// A file is a pointer to a [[vtable]] which allows for user-defined I/O
// abstractions to implement some subset of read, write, seek, close, and other
// I/O functionality in userspace.
export type file = *vtable;

// Indicates an end-of-file condition.
export type EOF = done;

// From "whence" a seek operation should occur.
export type whence = enum {
	SET = 0, // Relative to beginning (i.e. set absolute position).
	CUR = 1, // Relative to current position.
	END = 2, // Relative to end of *file.
};

// The vtable type defines a set of virtual functions for a [[file]].
export type vtable = struct {
	read: nullable *fn_file_read,
	write: nullable *fn_file_write,
	seek: nullable *fn_file_seek,
	readdir: nullable *fn_file_readdir,
	close: nullable *fn_file_close,
};

// Performs a read on a [[file]]. The provided buffer is not checked for
// validity within the current address space by the implementation.
export type fn_file_read = fn(s: *file, buf: []u8) (size | EOF | error);

// Performs a write on a [[file]]. The provided buffer is not checked for
// validity within the current address space by the implementation.
export type fn_file_write = fn(s: *file, buf: const []u8) (size | error);

// Closes a file and frees resources associated with it.
export type fn_file_close = fn(s: *file) (void | error);

// Seeks a file to the requested offset, returning the new offset.
export type fn_file_seek = fn(s: *file, off: i64, w: whence) (i64 | error);

// Reads the next directory from a file descriptor.
export type fn_file_readdir = fn(fd: *file, dent: *dirent) (void | EOF | error);

// Performs a read on a [[file]]. The provided buffer is not checked for
// validity within the current address space by the implementation.
export fn read(file: *file, buf: []u8) (size | EOF | error) = {
	match (file.read) {
	case let func: *fn_file_read =>
		return func(file, buf);
	case null =>
		return errno::NOTSUP: error;
	};
};

// Performs a write on a [[file]]. The provided buffer is not checked for
// validity within the current address space by the implementation.
export fn write(file: *file, buf: []u8) (size | error) = {
	match (file.write) {
	case let func: *fn_file_write =>
		return func(file, buf);
	case null =>
		return errno::NOTSUP: error;
	};
};

// Seeks a file to the requested offset, returning the new offset.
export fn seek(file: *file, offs: i64, w: whence) (i64 | error) = {
	match (file.seek) {
	case let func: *fn_file_seek =>
		return func(file, offs, w);
	case null =>
		return errno::NOTSUP: error;
	};
};

// Returns the current offset within a [[file]].
export fn tell(f: *file) (i64 | error) = {
	return seek(f, 0, whence::CUR);
};

// Reads the next directory from a file descriptor.
export fn readdir(file: *file, dent: *dirent) (void | EOF | error) = {
	match (file.readdir) {
	case let func: *fn_file_readdir =>
		return func(file, dent);
	case null =>
		return errno::NOTSUP;
	};
};

// Closes a [[file]]. No further operations against this file are permitted
// after calling this function.
export fn close(s: *file) (void | error) = {
	match (s.close) {
	case null => void;
	case let c: *fn_file_close =>
		c(s)?;
	};
};
