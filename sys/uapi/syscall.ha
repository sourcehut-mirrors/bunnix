use errors::{error, errno};
use log;

const UAPI: str = "uapi";

export fn syscall(
	sysno: u64,
	a1: u64,
	a2: u64,
	a3: u64,
	a4: u64,
	a5: u64,
) (u64, u64) = {
	if (sysno: size >= len(systab)) {
		return (errno::NOSYS, 0);
	};
	const func = systab[sysno]: *syscall_handler;
	match (func(a1, a2, a3, a4, a5)) {
	case let e: error =>
		return (e: errno, 0);
	case let u: u64 =>
		return (errno::NONE, u);
	};
};

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
	GETCREDS,
	KILL,
	EXIT,
	SIGACTION,
	MMAP,
	MUNMAP,
	MPROTECT,
	FORK,
	EXECVE,
	WAITPID,
	GETTIME,
	NANOSLEEP,
	FSTATAT,
	PIPE,
	CHDIRAT,
	DUP,
	DUP2,
	GETCWD,
	FCNTL,
	SETCREDS,
	SETGROUPS,
	MOUNT,
};

export type syscall_handler = fn(u64, u64, u64, u64, u64) (u64 | error);

let systab: [_]*opaque = [
	&sys_readv: *syscall_handler,
	&sys_writev: *syscall_handler,
	&sys_lseek: *syscall_handler,
	&sys_close: *syscall_handler,
	&sys_openat: *syscall_handler,
	&sys_mkdirat: *syscall_handler,
	&sys_linkat: *syscall_handler,
	&sys_unlinkat: *syscall_handler,
	&sys_getdents: *syscall_handler,
	&sys_getcreds: *syscall_handler,
	&sys_kill: *syscall_handler,
	&sys_exit: *syscall_handler,
	&sys_sigaction: *syscall_handler,
	&sys_mmap: *syscall_handler,
	&sys_munmap: *syscall_handler,
	&sys_mprotect: *syscall_handler,
	&sys_fork: *syscall_handler,
	&sys_execve: *syscall_handler,
	&sys_waitpid: *syscall_handler,
	&sys_gettime: *syscall_handler,
	&sys_nanosleep: *syscall_handler,
	&sys_fstatat: *syscall_handler,
	&sys_pipe: *syscall_handler,
	&sys_chdirat: *syscall_handler,
	&sys_dup: *syscall_handler,
	&sys_dup2: *syscall_handler,
	&sys_getcwd: *syscall_handler,
	&sys_fcntl: *syscall_handler,
	&sys_setcreds: *syscall_handler,
	&sys_setgroups: *syscall_handler,
	&sys_mount: *syscall_handler,
];

const sysname = [
	"readv",
	"writev",
	"lseek",
	"close",
	"openat",
	"mkdirat",
	"linkat",
	"unlinkat",
	"getdents",
	"getcreds",
	"kill",
	"exit",
	"sigaction",
	"mmap",
	"munmap",
	"mprotect",
	"fork",
	"execve",
	"waitpid",
	"gettime",
	"nanosleep",
	"fstatat",
	"pipe",
	"chdirat",
	"dup",
	"dup2",
	"getcwd",
	"fcntl",
	"setcreds",
	"setgroups",
	"mount",
];
