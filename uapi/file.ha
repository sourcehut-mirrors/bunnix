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

	abort(); // TODO
};

fn sys_preadv(
	fd: i64,
	off: i64,
	vecs: *[*]vector,
	nvec: u64,
) (u64 | error) = {
	validate_vectors(vecs, nvec, false)?;
	const vecs = vecs[..nvec];
	const file = validate_file(fd)?;

	abort(); // TODO
};

fn sys_writev(fd: int, vecs: *[*]vector, nvec: u64) (u64 | error) = {
	validate_vectors(vecs, nvec, true)?;
	const vecs = vecs[..nvec];
	const file = validate_file(fd)?;

	abort(); // TODO
};

fn sys_pwritev(
	fd: i64,
	off: i64,
	vecs: *[*]vector,
	nvec: u64,
) (u64 | error) = {
	validate_vectors(vecs, nvec, true)?;
	const vecs = vecs[..nvec];
	const file = validate_file(fd)?;

	abort(); // TODO
};

fn sys_lseek(
	fd: i64,
	off: i64,
	whence: io::whence,
) (u64 | error) = {
	abort(); // TODO
};

fn sys_close(
	fd: i64,
) (u64 | error) = {
	abort(); // TODO
};
