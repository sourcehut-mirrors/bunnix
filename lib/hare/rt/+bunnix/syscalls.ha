// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

fn syscall(sysno: u64, ...) (u64, u64);

export fn readv(fd: int, vec: const *[*]iovec, iovcnt: int) (size | errno) = {
	return syswrap(syscall(sys::READV,
			fd: i64, &vec[0], iovcnt: i64))?: size;
};

export fn read(fd: int, buf: *opaque, count: size) (size | errno) = {
	const vec = [
		iovec {
			iov_base = buf,
			iov_len = count,
		},
	];
	return readv(fd, &vec, 1);
};

export fn writev(fd: int, vec: const *[*]iovec, iovcnt: int) (size | errno) = {
	return syswrap(syscall(sys::WRITEV,
			fd: i64, &vec[0], iovcnt: i64))?: size;
};

export fn write(fd: int, buf: *opaque, count: size) (size | errno) = {
	const vec = [
		iovec {
			iov_base = buf,
			iov_len = count,
		},
	];
	return writev(fd, &vec, 1);
};

export fn lseek(fd: int, off: off_t, whence: int) (i64 | errno) = {
	return syswrap(syscall(sys::LSEEK, fd: i64, off, whence: i64))?: i64;
};

export fn close(fd: int) (void | errno) = {
	syswrap(syscall(sys::CLOSE, fd: i64))?;
};

export fn open(path: str, flags: int, mode: uint) (int | errno) = {
	const opts = openat_options {
		dirfd = AT_FDCWD,
		path = path,
		flags = flags,
		mode = mode,
	};
	return syswrap(syscall(sys::OPENAT, &opts))?: int;
};

export fn mkdir(path: str, mode: uint) (void | errno) = {
	const opts = mkdirat_options {
		dirfd = AT_FDCWD,
		path = path,
		mode = mode,
	};
	syswrap(syscall(sys::MKDIRAT, &opts))?;
};

export fn link(
	oldpath: str,
	newpath: str,
) (void | errno) = {
	const opts = linkat_options {
		olddirfd = AT_FDCWD,
		oldpath = oldpath,
		newdirfd = AT_FDCWD,
		newpath = newpath,
		flags = 0,
	};
	syswrap(syscall(sys::LINKAT, &opts))?;
};

export fn unlink(path: str) (void | errno) = {
	const opts = unlinkat_options {
		dirfd = AT_FDCWD,
		path = path,
		flags = 0,
	};
	syswrap(syscall(sys::UNLINKAT, &opts))?;
};

export fn getdents(fd: int, buf: *[*]u8, bufsz: size) (size | errno) = {
	return syswrap(syscall(sys::GETDENTS, fd: i64, buf, bufsz))?: size;
};

export fn getcreds(out: *creds) void = {
	syswrap(syscall(sys::GETCREDS, out))!;
};

export fn getpid() pid_t = {
	let creds = creds { ... };
	getcreds(&creds);
	return creds.pid;
};

export fn getppid() pid_t = {
	let creds = creds { ... };
	getcreds(&creds);
	return creds.ppid;
};

export fn getpgid() pid_t = {
	let creds = creds { ... };
	getcreds(&creds);
	return creds.pgid;
};

export fn getsid() pid_t = {
	let creds = creds { ... };
	getcreds(&creds);
	return creds.sid;
};

export fn getuid() uid_t = {
	let creds = creds { ... };
	getcreds(&creds);
	return creds.uid;
};

export fn geteuid() uid_t = {
	let creds = creds { ... };
	getcreds(&creds);
	return creds.euid;
};

export fn getgid() gid_t = {
	let creds = creds { ... };
	getcreds(&creds);
	return creds.gid;
};

export fn getegid() gid_t = {
	let creds = creds { ... };
	getcreds(&creds);
	return creds.egid;
};


export fn exit(status: int) never = {
	syscall(sys::EXIT, status: u64);
	abort();
};

export fn mmap(
	addr: nullable *opaque,
	length: size,
	prot: uint,
	flags: uint,
	fd: int,
	offs: off_t
) (*opaque | errno) = {
	const opts = mmap_options {
		addr = addr,
		length = length,
		prot = prot: int,
		flags = flags: int,
		fd = fd,
		offs = offs,
	};
	const r = syswrap(syscall(sys::MMAP, &opts))?;
	return r: uintptr: *opaque;
};

export fn munmap(addr: *opaque, length: size) (void | errno) = {
	syswrap(syscall(sys::MUNMAP, addr, length))?;
};

export fn fork() (pid_t | errno) = {
	return syswrap(syscall(sys::FORK))?: pid_t;
};

export fn execve(path: str, args: []str, env: []str) (void | errno) = {
	const opts = exec_options {
		flags = exec_flag::NONE,
		path = path,
		args = args,
		environ = env,
	};
	return syswrap(syscall(sys::EXECVE, &opts))?: pid_t;
};

export fn fexecve(fd: int, args: []str, env: []str) (void | errno) = {
	const opts = exec_options {
		flags = exec_flag::FEXECVE,
		fd = fd,
		args = args,
		environ = env,
	};
	return syswrap(syscall(sys::EXECVE, &opts))?: pid_t;
};

export fn waitpid(
	pid: pid_t,
	wstatus: nullable *int,
	options: int,
) (pid_t | errno) = {
	return syswrap(syscall(sys::WAITPID, pid: u64, wstatus, options: u64))?: pid_t;
};

export fn gettime(clock: int, tp: *timespec) (void | errno) = {
	syswrap(syscall(sys::GETTIME, clock: i64, tp))?;
};

export fn nanosleep(req: *timespec) (void | errno) = {
	syswrap(syscall(sys::NANOSLEEP, req))?;
};

export fn fstatat(
	dirfd: int,
	path: str,
	statbuf: *st,
	flags: int,
) (errno | void) = {
	const opts = fstatat_options {
		dirfd = dirfd,
		path = path,
		stat = statbuf,
		flags = flags,
	};
	syswrap(syscall(sys::FSTATAT, &opts))?;
};

export fn pipe(pipefd: *[2]int, flags: int) (void | errno) = {
	syswrap(syscall(sys::PIPE, pipefd, flags: i64))?;
};
