fn syscall(sysno: u64, ...) (u64, u64);

fn syswrap(ret: (u64, u64)) (u64 | error) = {
	const (status, result) = ret;
	if (status == errno::NONE) {
		return result;
	};
	return status: errno: error;
};

export fn readv(fd: i64, vec: vector...) (size | error) = {
	return syswrap(syscall(sys::READV, fd, &vec[0], len(vec)))?: size;
};

export fn writev(fd: i64, vec: vector...) (size | error) = {
	return syswrap(syscall(sys::WRITEV, fd, &vec[0], len(vec)))?: size;
};
