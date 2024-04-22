// Error number assignments.
export type errno = enum uint {
	NONE = 0,
	NOMEM,
	OVERFLOW,
	INVAL,
	EXIST,
};

// Error condition.
export type error = !errno;
