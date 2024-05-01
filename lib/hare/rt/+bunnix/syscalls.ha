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

export fn getpid() pid_t = {
	return syswrap(syscall(sys::GETPID))!: pid_t;
};

export fn getppid() pid_t = {
	return syswrap(syscall(sys::GETPPID))!: pid_t;
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

export fn open(path: str, flags: int, mode: uint) (int | errno) = {
	const opts = openat_options {
		dirfd = AT_FDCWD,
		path = path,
		flags = flags,
		mode = mode,
	};
	return syswrap(syscall(sys::OPENAT, &opts))?: int;
};
