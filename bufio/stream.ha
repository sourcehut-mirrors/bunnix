// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bytes;
use encoding::utf8;
use errors::{error, errno};
use io;
use strings;

const vtable_r: io::vtable = io::vtable {
	read = &read,
	close = &close_static,
	...
};

const vtable_w: io::vtable = io::vtable {
	write = &write,
	close = &close_static,
	...
};

const vtable_rw: io::vtable = io::vtable {
	read = &read,
	write = &write,
	close = &close_static,
	...
};

export type file = struct {
	file: io::file,
	source: *io::file,
	rbuffer: []u8,
	wbuffer: []u8,
	rpos: size,
	ravail: size,
	wavail: size,
	flush: []u8,
};

// Creates a file which buffers reads and writes for the underlying file.
// This is generally used to improve performance of small reads/writes for
// sources where I/O operations are costly, such as if they invoke a syscall or
// take place over the network.
//
// The caller should supply one or both of a read and write buffer as a slice of
// the desired buffer, or empty slices if read or write functionality is
// disabled. The same buffer may not be used for both reads and writes.
//
// The caller is responsible for closing the underlying file, and freeing the
// provided buffers if necessary, after the buffered file is closed.
//
// 	let rbuf: [os::BUFSZ]u8 = [0...];
// 	let wbuf: [os::BUFSZ]u8 = [0...];
// 	let buffered = bufio::init(source, rbuf, wbuf);
export fn init(
	src: *io::file,
	rbuf: []u8,
	wbuf: []u8,
) file = {
	static let flush_default = ['\n': u8];

	let st =
		if (len(rbuf) != 0 && len(wbuf) != 0) {
			assert(rbuf: *[*]u8 != wbuf: *[*]u8,
				"Cannot use same buffer for reads and writes");
			yield &vtable_rw;
		} else if (len(rbuf) != 0) {
			yield &vtable_r;
		} else if (len(wbuf) != 0) {
			yield &vtable_w;
		} else {
			abort("Must provide at least one buffer");
		};

	return file {
		file = st,
		source = src,
		rbuffer = rbuf,
		wbuffer = wbuf,
		flush = flush_default,
		rpos = len(rbuf), // necessary for unread() before read()
		...
	};
};

// Flushes pending writes to the underlying file.
export fn flush(s: *io::file) (void | error) = {
	assert(s.write == &write);
	const s = s: *file;
	if (s.wavail == 0) {
		return;
	};
	io::writeall(s.source, s.wbuffer[..s.wavail])?;
	s.wavail = 0;
	return;
};

// Sets the list of bytes which will cause the file to flush when written. By
// default, the file will flush when a newline (\n) is written.
export fn setflush(s: *io::file, b: []u8) void = {
	const s = s: *file;
	s.flush = b;
};

// "Unreads" a slice of bytes, such that the next call to "read" will return
// these bytes before reading any new data from the underlying source. The
// unread data must fit into the read buffer's available space. The amount of
// data which can be unread before the user makes any reads from a buffered
// file is equal to the length of the read buffer, and otherwise it is equal
// to the length of the return value of the last call to [[io::read]] using this
// buffered file. Attempting to unread more data than can fit into the read
// buffer will abort the program.
export fn unread(st: *io::file, buf: []u8) void = {
	switch (st.read) {
	case &read =>
		file_unread(st: *file, buf);
	case &scan_read =>
		scan_unread(st: *scanner, buf);
	case =>
		abort("Attempted unread on unbuffered file");
	};
};

fn file_unread(s: *file, buf: []u8) void = {
	assert(s.rpos >= len(buf),
		"Attempted to unread more data than buffer has available");
	s.rbuffer[s.rpos - len(buf)..s.rpos] = buf;
	s.rpos -= len(buf);
	s.ravail += len(buf);
};

// Unreads a rune; see [[unread]].
export fn unreadrune(s: *io::file, rn: rune) void = {
	const buf = utf8::encoderune(rn);
	unread(s, buf);
};

// Returns true if an [[io::file]] is a [[file]].
export fn isbuffered(in: *io::file) bool = {
	return in.read == &read || in.write == &write;
};

fn close_static(s: *io::file) (void | error) = {
	assert(s.close == &close_static);
	if (s.write != null) {
		flush(s: *file)?;
	};
};

fn read(s: *io::file, buf: []u8) (size | io::EOF | error) = {
	assert(s.read == &read);
	let s = s: *file;

	if (s.ravail < len(buf) && s.ravail < len(s.rbuffer)) {
		s.rbuffer[..s.ravail] = s.rbuffer[s.rpos..s.rpos + s.ravail];
		s.rpos = 0;
		match (io::read(s.source, s.rbuffer[s.ravail..])) {
		case let err: error =>
			return err;
		case io::EOF =>
			if (s.ravail == 0) {
				return io::EOF;
			};
		case let z: size =>
			s.ravail += z;
		};
	};

	const n = if (len(buf) < s.ravail) len(buf) else s.ravail;
	buf[..n] = s.rbuffer[s.rpos..s.rpos + n];
	s.rpos += n;
	s.ravail -= n;
	return n;
};

fn write(s: *io::file, buf: const []u8) (size | error) = {
	assert(s.write == &write);
	let s = s: *file;
	let buf = buf;

	let doflush = false;
	if (len(s.flush) != 0) {
		for :search (let i = 0z; i < len(buf); i += 1) {
			for (let j = 0z; j < len(s.flush); j += 1) {
				if (buf[i] == s.flush[j]) {
					doflush = true;
					break :search;
				};
			};
		};
	};

	let z = 0z;
	for (len(buf) > 0) {
		let avail = len(s.wbuffer) - s.wavail;
		if (avail == 0) {
			flush(s)?;
			avail = len(s.wbuffer);
		};

		const n = if (avail < len(buf)) avail else len(buf);
		s.wbuffer[s.wavail..s.wavail + n] = buf[..n];
		buf = buf[n..];
		s.wavail += n;
		z += n;
	};

	if (doflush) {
		flush(s)?;
	};

	return z;
};
