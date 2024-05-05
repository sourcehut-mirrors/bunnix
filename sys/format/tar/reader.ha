// License: MPL-2.0
// (c) 2022 Drew DeVault <sir@cmpwn.com>
use bytes;
use endian;
use errors;
use io;
use memio;
use strconv;
use strings;

export type reader = struct {
	src: *io::file,
	name: [255]u8,
	padding: size,
};

// Creates a new reader for a tar file. Use [[next]] to iterate through entries
// present in the tar file.
export fn read(src: *io::file) reader = {
	return reader {
		src = src,
		...
	};
};

// Returns the next entry from a tar [[reader]]. Parts of this structure
// (specifically the file name) are borrowed from the reader itself and will not
// be valid after subsequent calls.
//
// If the return value is a file (i.e. entry.etype == entry_type::FILE), the
// caller must either call [[io::read]] using the return value until it returns
// [[io::EOF]], or call [[skip]] to seek to the next entry in the archive.
//
// Note that reading from the header will modify the file size.
export fn next(rd: *reader) (entry | error | io::EOF) = {
	static let buf: [BLOCKSIZE]u8 = [0...];

	// Read any padding data from the previous file, if necessary
	if (rd.padding != 0) {
		match (io::read(rd.src, buf[..rd.padding])) {
		case let z: size =>
			if (z != rd.padding) {
				return truncated;
			};
			rd.padding = 0;
		case io::EOF =>
			return truncated;
		};
	};

	match (io::read(rd.src, buf)?) {
	case let z: size =>
		if (z != len(buf)) {
			return truncated;
		};
	case io::EOF =>
		return io::EOF;
	};

	if (zeroed(buf)) {
		match (io::read(rd.src, buf)?) {
		case let z: size =>
			if (z != len(buf)) {
				return truncated;
			};
		case io::EOF =>
			return io::EOF;
		};
		if (!zeroed(buf)) {
			return truncated;
		};
		return io::EOF;
	};

	const reader = memio::fixed(buf);
	let name = readstr(&reader, 100);
	let ent = entry {
		vtable = &null_vtable,
		src = null: *io::file,
		name = name,
		mode = readoct(&reader, 8)?,
		uid = readoct(&reader, 8)?,
		gid = readoct(&reader, 8)?,
		fsize = readsize(&reader, 12)?,
		mtime = readoct(&reader, 12)?,
		checksum = readoct(&reader, 8)?,
		etype = readoct(&reader, 1)?: entry_type,
		link = readstr(&reader, 100),
		...
	};

	if (ent.etype == entry_type::FILE) {
		ent.vtable = &file_vtable;
		ent.src = rd.src;
		ent.orig = ent.fsize;
		ent.remain = ent.orig;
	} else {
		ent.vtable = &null_vtable;
	};

	if (ent.fsize % BLOCKSIZE != 0) {
		rd.padding = BLOCKSIZE - (ent.orig % BLOCKSIZE);
	};

	const ustar = readstr(&reader, 6);
	if (ustar != "ustar") {
		ent.name = name;
		return ent;
	};

	const version = readstr(&reader, 2);
	// XXX: We could check the version here
	ent.uname = readstr(&reader, 32);
	ent.gname = readstr(&reader, 32);
	ent.devmajor = readoct(&reader, 8)?;
	ent.devminor = readoct(&reader, 8)?;
	const prefix = readstr(&reader, 155);
	let writer = memio::fixed(rd.name);
	memio::join(&writer, prefix, name)!;
	ent.name = memio::string(&writer)!;
	return ent;
};

// Seeks the tar file to the start.
export fn reset(rd: *reader) (void | errors::error) = {
	io::seek(rd.src, 0, io::whence::SET)?;
	rd.padding = 0;
};

// Seeks the underlying tar file to the entry following this one.
export fn skip(ent: *entry) (void | errors::error) = {
	if (ent.etype != entry_type::FILE) {
		return;
	};

	const amt = ent.remain;
	match (io::seek(ent.src, amt: i64, io::whence::CUR)) {
	case i64 =>
		return;
	case errors::error =>
		yield;
	};
	io::copy(io::empty, ent)?;
};

const null_vtable = io::vtable { ... };

const file_vtable = io::vtable {
	read = &file_read,
	seek = &file_seek,
	...
};

fn file_read(s: *io::file, buf: []u8) (size | io::EOF | errors::error) = {
	let ent = s: *ent_reader;
	assert(ent.vtable == &file_vtable);
	if (ent.remain == 0) {
		return io::EOF;
	};

	let z = len(buf);
	if (z > ent.remain) {
		z = ent.remain;
	};
	z = match (io::read(ent.src, buf[..z])?) {
	case let z: size =>
		yield z;
	case io::EOF =>
		// TODO: Truncated flag
		return io::EOF;
	};
	ent.remain -= z;
	return z;
};

fn file_seek(
	s: *io::file,
	off: i64,
	w: io::whence,
) (i64 | errors::error) = {
	let ent = s: *ent_reader;
	assert(ent.vtable == &file_vtable);

	const orig = ent.orig: i64;
	const cur = (ent.orig - ent.remain): i64;
	let new = switch (w) {
	case io::whence::SET =>
		yield off;
	case io::whence::CUR =>
		yield cur + off;
	case io::whence::END =>
		yield orig + off;
	};

	if (new < 0) {
		new = 0;
	} else if (new > orig) {
		new = orig;
	};

	const rel = new - cur;
	io::seek(ent.src, rel, io::whence::CUR)?;

	ent.remain = (orig - new): size;
	return new;
};

fn readstr(rd: *memio::file, ln: size) str = {
	const buf = match (memio::borrowedread(rd, ln)) {
	case let buf: []u8 =>
		assert(len(buf) == ln);
		yield buf;
	case io::EOF =>
		abort();
	};
	return strings::rtrim(strings::fromutf8(buf[..ln])!, ' ', '\0');
};

fn readoct(rd: *memio::file, ln: size) (uint | invalid) = {
	const string = readstr(rd, ln);
	if (len(string) == 0) {
		return 0; // XXX: is that right?
	};
	match (strconv::stou(string, strconv::base::OCT)) {
	case let u: uint =>
		return u;
	case =>
		return invalid;
	};
};

fn readsize(rd: *memio::file, ln: size) (size | invalid) = {
	const string = readstr(rd, ln);
	match (strconv::stoz(string, strconv::base::OCT)) {
	case let z: size =>
		return z;
	case =>
		return invalid;
	};
};

fn zeroed(buf: []u8) bool = {
	for (let i = 0z; i < len(buf); i += 1) {
		if (buf[i] != 0) {
			return false;
		};
	};
	return true;
};
