use errors::{error, errno};

export type sys = enum u64 {
	READV,
	PREADV,
	WRITEV,
	PWRITEV,
	LSEEK,
	CLOSE,
};

export type syscall_handler = fn(...) (u64 | error);

let systab: [_]*opaque = [
	&sys_readv,
	&sys_preadv,
	&sys_writev,
	&sys_pwritev,
	&sys_lseek,
	&sys_close,
];
