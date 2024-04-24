// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};

// Indicates an end-of-file condition.
export type EOF = done;

// File offset.
export type off = i64;

// From "whence" a seek operation should occur.
export type whence = enum {
	SET = 0, // Relative to beginning (i.e. set absolute position).
	CUR = 1, // Relative to current position.
	END = 2, // Relative to end of *stream.
};

// The interface for a stream which can be read from. Reads up to len(buf)
// bytes from the reader into the given buffer, returning the number of bytes
// read or an error.
export type reader = fn(s: *stream, buf: []u8) (size | EOF | error);

// The interface for a stream which can be written to. Writes up to len(buf)
// bytes to the writer from the given buffer, returning the number of bytes
// written or an error.
export type writer = fn(s: *stream, buf: const []u8) (size | error);

// The interface for a stream which can be closed. This function should close
// and free any underlying resources, and cannot be used again.
export type closer = fn(s: *stream) (void | error);

// The interface for a stream which can be seeked. Sets the offset for the next
// read or write to offset, interpreted according to whence:
// whence::SET means relative to the start of the file,
// whence::CUR means relative to the current offset, and
// whence::END means relative to the end.
//
// Returns the new offset relative to the start or an error.
export type seeker = fn(s: *stream, off: off, w: whence) (off | error);
