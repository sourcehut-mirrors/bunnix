// Error number assignments.
export type errno = enum uint {
	NONE = 0,
	NOMEM,
	OVERFLOW,
	UNDERFLOW,
	INVAL,
	EXIST,
	NOTSUP,
	NOENT,
	BUSY,
	PERM,
	IO,
	NXIO,
	E2BIG,
	ACCESS,
	FAULT,
	NODEV,
	NOTDIR,
	ISDIR,
	FBIG,
	NOSPC,
	ROFS,
	MLINK,
	RANGE,
	NOTEMPTY,
	NODATA,
	NOEXEC,
	NOSYS,
	BADF,
};

// Error condition.
export type error = !errno;
