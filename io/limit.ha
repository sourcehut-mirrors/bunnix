// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};

export type limitfile = struct {
	vtable: file,
	source: *file,
	limit: size,
};

const limit_vtable_reader: vtable = vtable {
	read = &limit_read,
	...
};

const limit_vtable_writer: vtable = vtable {
	write = &limit_write,
	...
};

// Create an overlay file that only allows a limited amount of bytes to be
// read from the underlying file. This file does not need to be closed, and
// closing it does not close the underlying file. Reading any data beyond the
// given limit causes the reader to return [[EOF]].
export fn limitreader(source: *file, limit: size) limitfile = {
	return limitfile {
		vtable = &limit_vtable_reader,
		source = source,
		limit = limit,
	};
};

// Create an overlay file that only allows a limited amount of bytes to be
// written to the underlying file. This file does not need to be closed, and
// closing it does not close the underlying file. Writing beyond the given
// limit causes the writer to return short writes (as few as zero bytes).
export fn limitwriter(source: *file, limit: size) limitfile = {
	return limitfile {
		vtable = &limit_vtable_writer,
		source = source,
		limit = limit,
	};
};

fn limit_read(s: *file, buf: []u8) (size | EOF | error) = {
	let file = s: *limitfile;
	if (file.limit == 0) {
		return EOF;
	};
	if (len(buf) > file.limit) {
		buf = buf[..file.limit];
	};
	match (read(file.source, buf)) {
	case EOF =>
		return EOF;
	case let z: size =>
		file.limit -= z;
		return z;
	};
};

fn limit_write(s: *file, buf: const []u8) (size | error) = {
	let file = s: *limitfile;
	if (file.limit == 0) {
		return 0z;
	};
	let slice = if (len(buf) > file.limit) {
		yield buf[..file.limit];
	} else {
		yield buf[..];
	};
	const z = write(file.source, slice)?;
	file.limit -= z;
	return z;
};
