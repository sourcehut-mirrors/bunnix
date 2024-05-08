use errors::{error, errno};
use io;
use proc;

fn sys_fcntl(fd: i64, cmd: i64, arg: i64) (u64 | error) = {
	def SETFL_MASK: io::flag =
		io::flag::APPEND |
		io::flag::NONBLOCK |
		io::flag::NOATIME;

	const cur = proc::current();
	const fd = proc::getfd(cur, fd: int)?;

	switch (cmd) {
	case F_DUPFD, F_DUPFD_CLOEXEC =>
		let fdno = arg: int;
		let newfd = proc::getavailfd(cur, &fdno)?;
		*newfd = *fd;
		io::ref(fd.file as *io::file);
		if (cmd == F_DUPFD_CLOEXEC) {
			fd.oflag |= io::flag::CLOEXEC;
		} else {
			fd.oflag &= ~io::flag::CLOEXEC;
		};
		return fdno: u64;
	case F_GETFD =>
		if (fd.oflag & io::flag::CLOEXEC != 0) {
			return FD_CLOEXEC: u64;
		} else {
			return 0u64;
		};
	case F_SETFD =>
		if (arg & FD_CLOEXEC != 0) {
			fd.oflag |= io::flag::CLOEXEC;
		} else {
			fd.oflag &= ~io::flag::CLOEXEC;
		};
		return 0u64;
	case F_GETFL =>
		return fd.oflag: u64;
	case F_SETFL =>
		const flag = arg: io::flag;
		const was_append = fd.oflag & io::flag::APPEND != 0;
		const is_append = flag & io::flag::APPEND != 0;
		if (!was_append && is_append) {
			io::seek(fd.file as *io::file, 0, io::whence::END)?;
		};

		fd.oflag |= flag & SETFL_MASK;
		return 0u64;
	case =>
		return errno::INVAL: error;
	};
};
