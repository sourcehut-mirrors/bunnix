// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use fs;
use io;
use path;
use rt;
use time;
use types::c;

type os_filesystem = struct {
	fs: fs::fs,
	getdents_bufsz: size,
};

// Returns the current working directory. The return value is statically
// allocated and must be duplicated (see [[strings::dup]]) before calling getcwd
// again.
export fn getcwd() str = {
	return "/"; // TODO
};

// Change the current working directory.
export fn chdir(target: (*fs::fs | str)) (void | fs::error) = {
	abort(); // TODO
};

// Changes the root directory of the process. Generally requires the caller to
// have root or otherwise elevated permissions.
//
// This function is not appropriate for sandboxing.
export fn chroot(target: str) (void | fs::error) = {
	abort(); // TODO
};

// Makes a FIFO node. This function is only available on Unix systems.
export fn mkfifo(path: str, mode: fs::mode) (void | fs::error) = {
	abort(); // TODO
};

// Makes a block device node. This function is only available on Unix-like
// systems.
export fn mkblk(
	path: str,
	mode: fs::mode,
	major: uint,
	minor: uint,
) (void | fs::error) = {
	abort(); // TODO
};

// Makes a character device node. This function is only available on Unix-like
// systems.
export fn mkchr(
	path: str,
	mode: fs::mode,
	major: uint,
	minor: uint,
) (void | fs::error) = {
	abort(); // TODO
};

// Access modes for [[access]].
export type amode = enum uint {
	F_OK = 1 << 0,
	R_OK = 1 << 1,
	W_OK = 1 << 2,
	X_OK = 1 << 3,
};

// Returns true if the given mode of access is permissible. The use of this
// function is discouraged as it can allow for a race condition to occur betwen
// testing for the desired access mode and actually using the file should the
// permissions of the file change between these operations. It is recommended
// instead to attempt to use the file directly and to handle any errors that
// should occur at that time.
export fn access(path: str, mode: amode) (bool | fs::error) = {
	return true; // TODO
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
			stat = &fs_stat,
			fstat = &fs_fstat,
			mkdir = &fs_mkdir,
			resolve = &fs_resolve,
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

fn fs_stat(fs: *fs::fs, path: str) (fs::filestat | fs::error) = {
	let fs = fs: *os_filesystem;
	let st = rt::st { ... };
	match (rt::fstatat(rt::AT_FDCWD, path, &st, 0)) {
	case let err: rt::errno =>
		return errno_to_fs(err);
	case void => void;
	};
	return st_to_filestat(&st);
};

fn fs_fstat(fs: *fs::fs, fd: io::file) (fs::filestat | fs::error) = {
	let fs = fs: *os_filesystem;
	let st = rt::st { ... };
	match (rt::fstatat(fd, "", &st, rt::AT_EMPTY_PATH)) {
	case let err: rt::errno =>
		return errno_to_fs(err);
	case void => void;
	};
	return st_to_filestat(&st);
};

fn st_to_filestat(st: *rt::st) fs::filestat = {
	return fs::filestat {
		mask = fs::stat_mask::UID
			| fs::stat_mask::GID
			| fs::stat_mask::SIZE
			| fs::stat_mask::INODE
			| fs::stat_mask::ATIME
			| fs::stat_mask::MTIME
			| fs::stat_mask::CTIME,
		mode = st.mode: fs::mode,
		uid = st.uid,
		gid = st.gid,
		sz = st.sz,
		inode = st.ino,
		atime = time::instant {
			sec = st.atime.tv_sec,
			nsec = st.atime.tv_nsec,
		},
		mtime = time::instant {
			sec = st.mtime.tv_sec,
			nsec = st.mtime.tv_nsec,
		},
		ctime = time::instant {
			sec = st.ctime.tv_sec,
			nsec = st.ctime.tv_nsec,
		},
	};
};

fn fs_resolve(fs: *fs::fs, path: str) str = {
	if (path::abs(path)) {
		return path;
	};
	static let buf = path::buffer { ... };
	path::set(&buf, getcwd(), path)!;
	return path::string(&buf);
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
