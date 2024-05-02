use errors::{error, errno};
use fs;
use io;
use proc;
use strings;

fn validate_file(fd: i64) (*io::file | error) = {
	const fds = &proc::current().fds;
	if (fd: size > len(fds)) {
		return errno::BADF;
	};
	const fd = match (fds[fd]) {
	case let fd: *io::file =>
		yield fd;
	case null =>
		return errno::BADF;
	};
	// TODO: Validate read/write access
	return fd;
};

fn sys_readv(fd: i64, vecs: *[*]vector, nvec: u64) (u64 | error) = {
	validate_vectors(vecs, nvec, false)?;
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
	validate_vectors(vecs, nvec, true)?;
	const vecs = vecs[..nvec];
	const file = validate_file(fd)?;

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
	const file = validate_file(fd)?;
	io::unref(file);
	proc::current().fds[fd] = null;
	return 0u64;
};

fn sys_openat(opts: *openat_options) (u64 | error) = {
	validate_user_addr(opts, size(openat_options))?;
	validate_user_string(opts.path)?;
	assert(opts.dirfd == AT_FDCWD);

	// TODO:
	// - free/unref inode from walk
	// - validate open flags
	const current = proc::current();
	const (inode, _) = fs::walk(current.root, opts.path)?;
	const file = io::inode_open(inode)?;
	const fd = proc::appendfd(current, file);
	return fd: u64;
};

fn sys_getdents(fd: i64, buf: *[*]u8, bufsz: size) (u64 | error) = {
	const file = validate_file(fd)?;
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
