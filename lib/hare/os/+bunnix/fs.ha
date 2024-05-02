// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use fs;
use rt;
use types::c;

type os_filesystem = struct {
	fs: fs::fs,
	getdents_bufsz: size,
};

@init fn init_cwd() void = {
	// TODO Bunnix
	static let cwd_fs = os_filesystem {
		fs = fs::fs {
			iter = &fs_iter,
			...
		},
		getdents_bufsz = 32768, // 32 KiB
		...
	};
	cwd = &cwd_fs;
};

fn errno_to_fs(err: rt::errno) fs::error = {
	switch (err) {
	case rt::ENOENT =>
		return errors::noentry;
	case rt::EEXIST =>
		return errors::exists;
	case rt::EACCES =>
		return errors::noaccess;
	case rt::EBUSY =>
		return errors::busy;
	case rt::ENOTDIR =>
		return fs::wrongtype;
	case rt::ENOSYS =>
		return errors::unsupported;
	case =>
		return errors::errno(err);
	};
};

type os_iterator = struct {
	iter: fs::iterator,
	fd: int,
	buf_pos: size,
	buf_end: size,
	buf: []u8,
};

fn fs_iter(fs: *fs::fs, path: str) (*fs::iterator | fs::error) = {
	const fs = fs: *os_filesystem;
	const oflags = rt::O_DIRECTORY | rt::O_CLOEXEC | rt::O_RDONLY;
	let fd = match (rt::open(path, oflags, 0)) {
	case let err: rt::errno =>
		return errno_to_fs(err);
	case let fd: int =>
		yield fd;
	};

	let buf: []u8 = alloc([0...], fs.getdents_bufsz);
	let iter = alloc(os_iterator {
		iter = fs::iterator {
			next = &iter_next,
			finish = &iter_finish,
		},
		fd = fd,
		buf = buf[..fs.getdents_bufsz],
		...
	});
	return &iter.iter;
};

fn iter_next(iter: *fs::iterator) (fs::dirent | done | fs::error) = {
	let iter = iter: *os_iterator;
	if (iter.buf_pos >= iter.buf_end) {
		let n = match (rt::getdents(iter.fd,
			iter.buf: *[*]u8, len(iter.buf))) {
		case let err: rt::errno =>
			return errno_to_fs(err);
		case let n: size =>
			yield n;
		};
		if (n == 0) {
			return done;
		};
		iter.buf_end = n;
		iter.buf_pos = 0;
	};
	let de = &iter.buf[iter.buf_pos]: *rt::dirent;
	iter.buf_pos += de.reclen;
	let name = c::tostr(&de.name: *const c::char)?;
	if (name == "." || name == "..") {
		return iter_next(iter);
	};

	return fs::dirent {
		name = name,
		ftype = de.mode: fs::mode,
	};
};

fn iter_finish(iter: *fs::iterator) void = {
	let iter = iter: *os_iterator;
	rt::close(iter.fd)!;
	free(iter.buf);
	free(iter);
};
