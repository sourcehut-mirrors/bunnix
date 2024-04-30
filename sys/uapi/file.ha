use errors::{error, errno};
use io;
use proc;

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
