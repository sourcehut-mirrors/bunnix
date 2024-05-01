export type off_t = i64;
export type dev_t = u64;
export type ino_t = u64;
export type nlink_t = u64;
export type mode_t = uint;
export type id_t = uint;
export type uid_t = uint;
export type gid_t = uint;
export type pid_t = int;

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

export def AT_FDCWD: int = -100;

export type openat_options = struct {
	dirfd: i64,
	path: str,
	flags: int,
	mode: uint,
};
