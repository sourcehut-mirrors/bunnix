// Based on Hare upstream's memio
// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};
use fs;

const file_impl_reg = fs::file_iface {
	read = &file_read,
	write = &file_write,
	seek = &file_seek,
	...
};

fn file_read(fd: *fs::file, buf: []u8) (size | fs::EOF | error) = {
	let fd = fd: *file;
	let inode = fd.inode: *inode;
	if (len(inode.data) == fd.pos) {
		return fs::EOF;
	};
	const n = if (len(inode.data) - fd.pos < len(buf)) {
		yield len(inode.data) - fd.pos;
	} else {
		yield len(buf);
	};
	assert(fd.pos + n <= len(inode.data));
	buf[..n] = inode.data[fd.pos..fd.pos + n];
	fd.pos += n;
	return n;
};

fn file_write(fd: *fs::file, buf: []u8) (size | error) = {
	let fd = fd: *file;
	let inode = fd.inode: *inode;
	let spare = len(inode.data) - fd.pos;
	let bufend = if (spare < len(buf)) spare else len(buf);
	inode.data[fd.pos..fd.pos+bufend] = buf[..bufend];
	fd.pos += bufend;
	if (bufend < len(buf)) {
		append(inode.data, buf[bufend..]...);
		fd.pos += len(buf[bufend..]);
	};
	return len(buf);
};

fn file_seek(fd: *fs::file, offs: i64, w: fs::whence) (size | error) = {
	let fd = fd: *file;
	let inode = fd.inode: *inode;
	let start = switch (w) {
	case fs::whence::SET => yield 0z;
	case fs::whence::CUR => yield fd.pos;
	case fs::whence::END => yield len(inode.data);
	};
	if (offs < 0) {
		if (start < (-offs): size) {
			return errno::INVAL: error;
		};
	} else {
		if (len(inode.data) - start < offs: size) {
			return errno::INVAL: error;
		};
	};
	fd.pos = start + offs: size;
	return fd.pos;
};
