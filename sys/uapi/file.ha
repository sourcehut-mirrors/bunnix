use errors::{error, errno};
use fs;
use io;
use proc;
use strings;

fn validate_file(fd: i64, write: bool = false) (*io::file | error) = {
	const fd = proc::getfd(proc::current(), fd: int)?;

	let flagvalid = true;
	if (fd.oflag & 3 == io::flag::RDWR) {
		void; // no-op
	} else if (fd.oflag & 3 == io::flag::RDONLY && write) {
		return errno::BADF;
	} else if (fd.oflag & 3 == io::flag::WRONLY && !write) {
		return errno::BADF;
	};

	match (fd.inode) {
	case let ino: *io::inode =>
		if (io::isdir(ino.mode)) {
			return errno::ISDIR;
		};
	case null => void;
	};

	return fd.file: *io::file;
};

fn validate_dirfd(fd: i64) (*io::file | error) = {
	const fd = proc::getfd(proc::current(), fd: int)?;

	match (fd.inode) {
	case let ino: *io::inode =>
		if (!io::isdir(ino.mode)) {
			return errno::NOTDIR;
		};
	case null => void;
	};

	return fd.file: *io::file;
};

fn sys_readv(fd: i64, vecs: *[*]vector, nvec: u64) (u64 | error) = {
	validate_vectors(vecs, nvec, true)?;
	const vecs = vecs[..nvec];
	const file = validate_file(fd)?;

	let sum = 0z;
	for (let vec .. vecs) {
		const buf = (vec.base: *[*]u8)[..vec.count];
		match (io::read(file, buf)?) {
		case let n: size =>
			sum += n;
			if (n < vec.count) {
				break;
			};
		case io::EOF =>
			break;
		};
	};

	return sum;
};

fn sys_writev(fd: i64, vecs: *[*]vector, nvec: u64) (u64 | error) = {
	validate_vectors(vecs, nvec)?;
	const vecs = vecs[..nvec];
	const file = validate_file(fd, true)?;

	let sum = 0z;
	for (let vec .. vecs) {
		const buf = (vec.base: *[*]u8)[..vec.count];
		const n = io::write(file, buf)?;
		sum += n;
		if (n < vec.count) {
			break;
		};
	};

	return sum;
};

fn sys_lseek(
	fd: i64,
	off: i64,
	whence: io::whence,
) (u64 | error) = {
	const file = validate_file(fd)?;
	return io::seek(file, off, whence)?: u64;
};

fn sys_close(
	fd: i64,
) (u64 | error) = {
	proc::closefd(proc::current(), fd: int)?;
	return 0u64;
};

fn sys_openat(opts: *openat_options) (u64 | error) = {
	// Note: our handling of O_DIRECTORY differs from POSIX:
	// - If you don't specify O_DIRECTORY, you cannot open a directory
	// - O_DIRECTORY is not compatible with O_CREATE (use mkdirat)
	// - O_DIRECTORY can only be opened O_RDONLY
	validate_user_addr(opts, size(openat_options))?;
	validate_user_string(opts.path)?;
	assert(opts.dirfd == AT_FDCWD);

	const current = proc::current();
	let walkflag = fs::walkflag::NONE;
	let oflag = opts.flags: io::flag;
	if (oflag & io::flag::CREATE != 0) {
		walkflag |= fs::walkflag::PARENT;
	};
	if (oflag & io::flag::DIRECTORY != 0) {
		if (oflag & io::flag::CREATE != 0) {
			return errno::ISDIR: error;
		};
		if (oflag & 3 != io::flag::RDONLY) {
			return errno::ACCES: error;
		};
	};

	let (inode, final) = fs::walk(current.root, opts.path, walkflag)?;
	if (oflag & io::flag::CREATE != 0) {
		const parent = inode;
		defer io::inode_unref(parent);

		inode = match (io::inode_lookup(parent, final)) {
		case let err: error =>
			if (err: errno != errno::NOENT) {
				return err;
			};

			const mode = opts.mode: io::mode;
			yield io::inode_create(inode, final, mode)?;
		case let ino: *io::inode =>
			if (oflag & io::flag::EXCL != 0) {
				io::inode_unref(ino);
				return errno::EXIST: error;
			};
			yield ino;
		};
	};

	if (oflag & io::flag::DIRECTORY != 0 && !io::isdir(inode.mode)) {
		return errno::NOTDIR: error;
	} else if (oflag & io::flag::DIRECTORY == 0 && io::isdir(inode.mode)) {
		return errno::ISDIR: error;
	};

	const file = io::inode_open(inode)?;

	if (oflag & io::flag::TRUNC != 0) {
		match (io::inode_trunc(inode, 0)) {
		case let err: error =>
			io::unref(file);
			return err;
		case void => void;
		};
	};

	if (oflag & io::flag::APPEND != 0) {
		match (io::seek(file, 0, io::whence::END)) {
		case let err: error =>
			io::unref(file);
			return err;
		case i64 => void;
		};
	};

	return proc::installfd(current, file, oflag, inode): u64;
};

fn sys_mkdirat(opts: *mkdirat_options) (u64 | error) = {
	validate_user_addr(opts, size(mkdirat_options))?;
	validate_user_string(opts.path)?;
	assert(opts.dirfd == AT_FDCWD);

	const current = proc::current();
	const walkflag = fs::walkflag::PARENT;
	let (parent, final) = fs::walk(current.root, opts.path, walkflag)?;
	const child = io::inode_mkdir(parent, final, opts.mode: io::mode)?;
	io::inode_unref(parent);
	io::inode_unref(child);

	return 0u64;
};

fn sys_linkat(opts: *linkat_options) (u64 | error) = {
	validate_user_addr(opts, size(linkat_options))?;
	validate_user_string(opts.oldpath)?;
	validate_user_string(opts.newpath)?;
	assert(opts.olddirfd == AT_FDCWD);
	assert(opts.newdirfd == AT_FDCWD);

	abort(); // TODO
};

fn sys_unlinkat(opts: *unlinkat_options) (u64 | error) = {
	validate_user_addr(opts, size(unlinkat_options))?;
	validate_user_string(opts.path)?;
	assert(opts.dirfd == AT_FDCWD);

	const current = proc::current();
	const (parent, final) = fs::walk(current.root,
		opts.path, fs::walkflag::PARENT)?;
	io::inode_unlink(parent, final)?;
	io::inode_unref(parent);

	return 0u64;
};

fn sys_getdents(fd: i64, buf: *[*]u8, bufsz: size) (u64 | error) = {
	const file = validate_dirfd(fd)?;
	validate_user_addr(buf, bufsz, true)?;
	const buf = buf[..bufsz];

	// Buffer must be able to store at least one dirent
	if (bufsz < size(dirent_meta) + fs::NAME_MAX + 1) {
		return errno::INVAL: error;
	};

	let n = 0z;
	for (bufsz - n >= size(dirent_meta) + fs::NAME_MAX + 1) {
		let next = &buf[n]: *dirent;

		let dent = io::dirent { ... };
		match (io::readdir(file, &dent)?) {
		case void => void;
		case io::EOF =>
			break;
		};

		const nameln = len(dent.name);
		next.ino = dent.ino;
		next.mode = dent.mode;
		next.reclen = nameln + size(dirent_meta) + 1;

		const name = strings::toutf8(dent.name);
		next.name[..nameln] = name[..];
		next.name[nameln] = 0;

		n += next.reclen;
		next.off = n;
	};

	return n: u64;
};
