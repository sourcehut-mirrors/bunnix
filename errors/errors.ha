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
};

// Error condition.
export type error = !errno;
