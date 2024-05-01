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

export def AT_FDCWD: int = -100;

export type openat_options = struct {
	dirfd: i64,
	path: str,
	flags: int,
	mode: uint,
};
