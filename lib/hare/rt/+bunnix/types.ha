export type off_t = i64;
export type dev_t = u64;
export type ino_t = u64;
export type nlink_t = u64;
export type mode_t = uint;
export type id_t = uint;
export type uid_t = uint;
export type gid_t = uint;
export type pid_t = int;

export def NGROUPS_MAX: size = 32;

export type creds = struct {
	// Process ID
	pid: pid_t,
	// Parent process ID
	ppid: pid_t,
	// Process group ID
	pgid: pid_t,
	// Session ID
	sid: pid_t,
	// User ID
	uid: uid_t,
	// Group ID
	gid: gid_t,
	// Effective user ID
	euid: uid_t,
	// Effective group ID
	egid: gid_t,
	// Number of supplementary group IDs
	ngroup: size,
	// Supplementary group IDs
	groups: []gid_t,
};

export def STDIN_FILENO: int = 0;
export def STDOUT_FILENO: int = 1;
export def STDERR_FILENO: int = 2;

export type iovec = struct {
	iov_base: *opaque,
	iov_len: size
};

export type mmap_options = struct {
	addr: nullable *opaque,
	length: size,
	prot: int,
	flags: int,
	fd: int,
	offs: off_t,
};

export def PROT_NONE: uint	= 0;
export def PROT_READ: uint	= 1;
export def PROT_WRITE: uint	= 2;
export def PROT_EXEC: uint	= 4;

export def MAP_ANON: uint		= 1 << 0;
export def MAP_PRIVATE: uint		= 1 << 1;
export def MAP_SHARED: uint		= 1 << 2;
export def MAP_FIXED: uint		= 1 << 3;

export type exec_flag = enum uint {
	NONE = 0,
	FEXECVE = 1 << 0,
};

export type exec_options = struct {
	// Flags for the operation
	flags: exec_flag,
	// Executable to execute
	union {
		path: str,
		fd: int,
	},
	// List of argument strings
	args: []str,
	// List of KEY=VALUE strings
	environ: []str,
};

// Matches Linux definitions
export def O_RDONLY: int	= 0o0;
export def O_WRONLY: int	= 0o1;
export def O_RDWR: int		= 0o2;
export def O_APPEND: int	= 0o2000;
export def O_CLOEXEC: int	= 0o2000000;
export def O_CREATE: int	= 0o100;
export def O_DIRECT: int	= 0o40000;
export def O_DIRECTORY: int	= 0o200000;
export def O_EXCLUSIVE: int	= 0o200;
export def O_NOFOLLOW: int	= 0o400000;
export def O_NONBLOCK: int	= 0o4000;
export def O_PATH: int		= 0o10000000;
export def O_TRUNC: int		= 0o1000;

export def DT_UNKNOWN = 0;
export def DT_FIFO = 0o010000;
export def DT_DIR = 0o040000;
export def DT_CHR = 0o020000;
export def DT_BLK = 0o060000;
export def DT_REG = 0o100000;
export def DT_LINK = 0o120000;
export def DT_SOCK = 0o140000;

export def AT_FDCWD: int = -100;

export def AT_SYMLINK_NOFOLLOW: int = 0x100;
export def AT_REMOVEDIR: int = 0x200;
export def AT_EMPTY_PATH: int = 0x1000;

export type openat_options = struct {
	dirfd: i64,
	path: str,
	flags: int,
	mode: uint,
};

export type mkdirat_options = struct {
	dirfd: i64,
	path: str,
	mode: uint,
};

export type linkat_options = struct {
	olddirfd: int,
	oldpath: str,
	newdirfd: int,
	newpath: str,
	flags: int,
};

export type unlinkat_options = struct {
	dirfd: int,
	path: str,
	flags: int,
};

export type dirent_meta = struct {
	ino: uint,
	off: size,
	reclen: size,
	mode: uint,
};

export type dirent = struct {
	dirent_meta,
	name: [*]u8,
};

export type st = struct {
	dev: u64,
	ino: u64,
	mode: uint,
	nlink: u64,
	uid: uint,
	gid: uint,
	rdev: u64,
	sz: u64,
	blksz: u64,
	blocks: u64,
	atime: timespec,
	mtime: timespec,
	ctime: timespec,
};

export type fstatat_options = struct {
	dirfd: int,
	path: str,
	stat: *st,
	flags: int,
};

export type timespec = struct {
	tv_sec: i64,
	tv_nsec: i64,
};

export def WNOHANG: int = 1;
export def WUNTRACED: int = 2;
export def WCONTINUED: int = 8;

export fn wexitstatus(s: int) int = (s & 0xff00) >> 8;
export fn wtermsig(s: int) int = s & 0x7f;
export fn wstopsig(s: int) int = wexitstatus(s);
export fn wcoredump(s: int) int = s & 0x80;
export fn wifexited(s: int) bool = wtermsig(s) <= 0;
export fn wifstopped(s: int) bool = (((s & 0xFFFF) * 0x10001) >> 8) > 0x7f00;
export fn wifsignaled(s: int) bool = (s & 0xFFFF) - 1 < 0xFF;
export fn wifcontinued(s: int) bool = s == 0xFFFF;

export type chdirat_options = struct {
	dirfd: int,
	path: str,
	flags: int, // AT_EMPTY_PATH
};
