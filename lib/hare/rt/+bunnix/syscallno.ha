// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

export type sys = enum u64 {
	READV,
	WRITEV,
	LSEEK,
	CLOSE,
	OPENAT,
	MKDIRAT,
	LINKAT,
	UNLINKAT,
	GETDENTS,
	GETPID,
	KILL,
	EXIT,
	MMAP,
	MUNMAP,
	MPROTECT,
	FORK,
	EXECVE,
	GETPPID,
	GETTIME,
	NANOSLEEP,
};
