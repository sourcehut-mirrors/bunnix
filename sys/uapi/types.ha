export type vector = struct {
	base: *opaque,
	count: size,
};

export type mmap_options = struct {
	addr: nullable *opaque,
	length: size,
	prot: int,
	flags: int,
	fd: int,
	offs: i64,
};

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
	dirfd: int,
	path: str,
	flags: int,
	mode: uint,
};

export type mkdirat_options = struct {
	dirfd: int,
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

export type dirent_meta = struct @packed {
	ino: u64,
	off: i64,
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

export type creds = struct {
	// Process ID
	pid: int,
	// Parent process ID
	ppid: int,
	// Process group ID
	pgid: int,
	// Session ID
	sid: int,
	// User ID
	uid: int,
	// Group ID
	gid: int,
	// Effective user ID
	euid: int,
	// Effective group ID
	egid: int,
	// Number of supplementary group IDs
	ngroup: size,
	// Supplementary group IDs
	groups: []int,
};

export type chdirat_options = struct {
	dirfd: int,
	path: str,
	flags: int, // AT_EMPTY_PATH for fchdir
};
