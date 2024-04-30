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
	FEXECVE = 1 << 0,
};

export type exec_options = struct {
	flags: exec_flag,
	union {
		struct {
			// Path to executable
			path: *[*]u8,
			pathlen: size,
		},
		fd: int,
	},
	// List of argument strings
	args: *[*]struct {
		arg: *[*]u8,
		arglen: size,
	},
	// List of KEY=VALUE strings
	environ: *[*]struct {
		env: *[*]u8,
		envlen: size,
	},
};
