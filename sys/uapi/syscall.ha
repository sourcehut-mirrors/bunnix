use errors::{error, errno};
use sched;

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
	let task = sched::current() as *sched::task;
	task.syscall = sysno: int;
	defer task.syscall = -1;

	const func = systab[sysno]: *syscall_handler;
	const rval = func(a1, a2, a3, a4, a5);
	match (rval) {
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
	FACCESSAT,
	UNAME,
	SETHOSTNAME,
	CHROOTAT,
	MKNODAT,
	BRK,
	UTIMENSAT,
};

export type syscall_handler = fn(u64, u64, u64, u64, u64) (u64 | error);

let systab: [_]*opaque = [
	&sys_readv,
	&sys_writev,
	&sys_lseek,
	&sys_close,
	&sys_openat,
	&sys_mkdirat,
	&sys_linkat,
	&sys_unlinkat,
	&sys_getdents,
	&sys_getcreds,
	&sys_kill,
	&sys_exit,
	&sys_sigaction,
	&sys_mmap,
	&sys_munmap,
	&sys_mprotect,
	&sys_fork,
	&sys_execve,
	&sys_waitpid,
	&sys_gettime,
	&sys_nanosleep,
	&sys_fstatat,
	&sys_pipe,
	&sys_chdirat,
	&sys_dup,
	&sys_dup2,
	&sys_getcwd,
	&sys_fcntl,
	&sys_setcreds,
	&sys_setgroups,
	&sys_mount,
	&sys_faccessat,
	&sys_uname,
	&sys_sethostname,
	&sys_chrootat,
	&sys_mknodat,
	&sys_brk,
	&sys_utimensat,
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
	"faccessat",
	"uname",
	"sethostname,"
	"chrootat",
	"mknodat",
	"brk",
	"utimensat",
];
