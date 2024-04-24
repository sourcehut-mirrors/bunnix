// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};

// A stream is a pointer to a [[vtable]] which allows for user-defined I/O
// abstractions to implement some subset of read, write, seek, close, and other
// I/O functionality in userspace. Embed to create a custom stream type:
//
//	export type my_stream = struct {
//		vtable: io::stream,
//		fd: int,
//	};
//
//	const my_vtable: io::vtable = io::vtable {
//		reader = &my_stream_read,
//		writer = &my_stream_write,
//		closer = null,
//		...
//	};
//
//	export fn open(path: str) my_stream = {
//		let fd = // ...
//		return my_stream {
//			vtable = &my_vtable,
//			fd = fd,
//			...
//		});
//	};
//
//	let stream = open("example");
//	io::read(&stream, buf)!;
export type stream = *vtable;

// The vtable type defines a set of virtual functions for a [[stream]].
export type vtable = struct {
	reader: nullable *reader,
	writer: nullable *writer,
	closer: nullable *closer,
	seeker: nullable *seeker,
};

// Reads up to len(buf) bytes from a [[stream]] into the given buffer, returning
// the number of bytes read.
export fn read(s: *stream, buf: []u8) (size | EOF | error) = {
	match (s.reader) {
	case null =>
		return errno::NOTSUP: error;
	case let r: *reader =>
		return r(s, buf);
	};
};

// Writes up to len(buf) bytes to the [[stream]] from the given buffer,
// returning the number of bytes written.
export fn write(s: *stream, buf: const []u8) (size | error) = {
	match (s.writer) {
	case null =>
		return errno::NOTSUP: error;
	case let w: *writer =>
		return w(s, buf);
	};
};

// Closes a [[stream]]. No further operations against this stream are permitted
// after calling this function.
export fn close(s: *stream) (void | error) = {
	match (s.closer) {
	case null => void;
	case let c: *closer =>
		c(s)?;
	};
};

// Sets the offset within a [[stream]], returning the new offset. The new offset
// is obtained by adding [[off]] to the position specified by [[whence]].
export fn seek(s: *stream, off: off, w: whence) (off | error) = {
	match (s.seeker) {
	case null =>
		return errno::NOTSUP: error;
	case let sk: *seeker =>
		return sk(s, off, w);
	};
};

// Returns the current offset within a [[stream]].
export fn tell(h: *stream) (off | error) = {
	return seek(h, 0, whence::CUR);
};
