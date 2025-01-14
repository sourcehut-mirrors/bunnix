// Based on Hare upstream's memio
// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};
use io;
use fs;

const file_impl_reg = io::vtable {
	read = &file_read,
	write = &file_write,
	seek = &file_seek,
	finish = &file_finish,
	...
};

fn file_read(fd: *io::file, buf: []u8) (size | io::EOF | error) = {
	let fd = fd: *file;
	let inode = fd.inode: *inode;
	if (fd.pos >= len(inode.data)) {
		return io::EOF;
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

fn file_write(fd: *io::file, buf: const []u8) (size | error) = {
	let fd = fd: *file;
	let inode = fd.inode: *inode;
	if (fd.pos >= len(inode.data)) {
		inode_trunc(inode, fd.pos)?;
	};

	let spare = len(inode.data) - fd.pos;
	let bufend = if (spare < len(buf)) spare else len(buf);
	inode.data[fd.pos..fd.pos+bufend] = buf[..bufend];
	fd.pos += bufend;
	if (bufend < len(buf)) {
		append(inode.data, buf[bufend..]...)!;
		fd.pos += len(buf[bufend..]);
	};
	fs::put_time(&inode.mtime);
	return len(buf);
};

fn file_seek(fd: *io::file, offs: i64, w: io::whence) (i64 | error) = {
	let fd = fd: *file;
	let inode = fd.inode: *inode;
	let start = switch (w) {
	case io::whence::SET => yield 0z;
	case io::whence::CUR => yield fd.pos;
	case io::whence::END => yield len(inode.data);
	};

	if (offs < 0) {
		if (start < (-offs): size) {
			return errno::INVAL: error;
		};
	};

	fd.pos = start + offs: size;
	return fd.pos: i64;
};
