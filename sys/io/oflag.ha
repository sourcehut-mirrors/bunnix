// Flags to use for opening a file. Not all operating systems support all flags;
// at a minimum, RDONLY, WRONLY, RDWR, CREATE, and TRUNC will be supported.
export type flag = enum int {
	RDONLY		= 0,
	WRONLY		= 1,
	RDWR		= 2,
	CREATE		= 0o100,
	EXCL		= 0o200,
	NOCTTY		= 0o400,
	TRUNC		= 0o1000,
	APPEND		= 0o2000,
	NONBLOCK	= 0o4000,
	DSYNC		= 0o10000,
	SYNC		= 0o4010000,
	RSYNC		= 0o4010000,
	DIRECTORY	= 0o200000,
	NOFOLLOW	= 0o400000,
	NOATIME		= 0o1000000,
	CLOEXEC		= 0o2000000,
	PATH		= 0o10000000,
	TMPFILE		= 0o20200000,
};
