// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use fs;
use io;
use rt;
use types::c;

type os_filesystem = struct {
	fs: fs::fs,
	getdents_bufsz: size,
};

@init fn init_cwd() void = {
	static let cwd_fs = os_filesystem {
		fs = fs::fs {
			open = &fs_open,
			openfile = &fs_open_file,
			create = &fs_create,
			createfile = &fs_create_file,
			remove = &fs_remove,
			iter = &fs_iter,
			mkdir = &fs_mkdir,
			...
		},
		getdents_bufsz = 32768, // 32 KiB
		...
	};
	cwd = &cwd_fs;
};

type os_iterator = struct {
	iter: fs::iterator,
	fd: int,
	buf_pos: size,
	buf_end: size,
	buf: []u8,
};

fn _fs_open(
	fs: *fs::fs,
	path: str,
	oflags: int,
	mode: uint,
) (io::file | fs::error) = {
	let fs = fs: *os_filesystem;

	const fd = match (rt::open(path, oflags, mode)) {
	case let err: rt::errno =>
		return errno_to_fs(err);
	case let fd: int =>
		yield fd;
	};

	return io::fdopen(fd);
};

fn fs_open_file(
	fs: *fs::fs,
	path: str,
	flags: fs::flag,
) (io::file | fs::error) = {
	flags ^= fs::flag::CTTY | fs::flag::NOCLOEXEC; // invert NOCTTY/CLOEXEC
	return _fs_open(fs, path, flags: int, 0);
};

fn fs_open(
	fs: *fs::fs,
	path: str,
	flags: fs::flag,
) (io::handle | fs::error) = fs_open_file(fs, path, flags)?;

fn fs_create_file(
	fs: *fs::fs,
	path: str,
	mode: fs::mode,
	flags: fs::flag,
) (io::file | fs::error) = {
	flags ^= fs::flag::CTTY | fs::flag::NOCLOEXEC; // invert NOCTTY/CLOEXEC
	flags |= fs::flag::CREATE;
	return _fs_open(fs, path, flags: int, mode: uint)?;
};

fn fs_create(
	fs: *fs::fs,
	path: str,
	mode: fs::mode,
	flags: fs::flag,
) (io::handle | fs::error) = {
	return fs_create_file(fs, path, mode, flags)?;
};

fn fs_remove(fs: *fs::fs, path: str) (void | fs::error) = {
	let fs = fs: *os_filesystem;
	match (rt::unlink(path)) {
	case let err: rt::errno =>
		return errno_to_fs(err);
	case void => void;
	};
};

fn fs_mkdir(
	fs: *fs::fs,
	path: str,
	mode: fs::mode,
) (void | fs::error) = {
	match (rt::mkdir(path, mode)) {
	case let err: rt::errno =>
		return errno_to_fs(err);
	case void =>
		return;
	};
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
