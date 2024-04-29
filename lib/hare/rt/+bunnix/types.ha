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
	offs: i64,
};

export def PROT_NONE: uint	= 0;
export def PROT_READ: uint	= 1;
export def PROT_WRITE: uint	= 2;
export def PROT_EXEC: uint	= 4;

export def MAP_ANON: uint		= 1 << 0;
export def MAP_PRIVATE: uint		= 1 << 1;
export def MAP_SHARED: uint		= 1 << 2;
export def MAP_FIXED: uint		= 1 << 3;
