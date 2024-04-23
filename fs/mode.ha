// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use strings;

// File mode information. These bits do not necessarily reflect the underlying
// operating system's mode representation, though they were chosen to be
// consistent with typical Unix file permissions. All implementations shall
// support at least USER_RW, DIR, and REG.
export type mode = enum uint {
	// Read, write, and execute permissions for the file owner
	USER_RWX	= 0o700,
	// Read and write permissions for the file owner
	USER_RW		= 0o600,
	// Read and execute permissions for the file owner
	USER_RX		= 0o500,
	// Read permissions for the file owner
	USER_R		= 0o400,
	// Write permissions for the file owner
	USER_W		= 0o200,
	// Execute permissions for the file owner
	USER_X		= 0o100,

	// Read, write, and execute permissions for group members
	GROUP_RWX	= 0o070,
	// Read and write permissions for group members
	GROUP_RW	= 0o060,
	// Read and execute permissions for group members
	GROUP_RX	= 0o050,
	// Read permissions for group members
	GROUP_R		= 0o040,
	// Write permissions for group members
	GROUP_W		= 0o020,
	// Execute permissions for group members
	GROUP_X		= 0o010,

	// Read, write, and execute permissions for other users
	OTHER_RWX	= 0o007,
	// Read and write permissions for other users
	OTHER_RW	= 0o006,
	// Read and execute permissions for other users
	OTHER_RX	= 0o005,
	// Read permissions for other users
	OTHER_R		= 0o004,
	// Write permissions for other users
	OTHER_W		= 0o002,
	// Execute permissions for other users
	OTHER_X		= 0o001,

	// Entry has the set-uid bit set
	SETUID	= 0o4000,
	// Entry has the set-gid bit set
	SETGID	= 0o2000,
	// Entry has the sticky bit set
	STICKY	= 0o1000,

	// Entry is of an unknown type
	UNKNOWN	= 0,
	// Entry is a FIFO (named pipe)
	FIFO	= 0o010000,
	// Entry is a directory
	DIR	= 0o040000,
	// Entry is a character device
	CHR	= 0o020000,
	// Entry is a block device
	BLK	= 0o060000,
	// Entry is a regular file
	REG	= 0o100000,
	// Entry is a symbolic link
	LINK	= 0o120000,
	// Entry is a Unix socket
	SOCK	= 0o140000,
};

// Converts a mode into a Unix-like mode string (e.g. "-rw-r--r--"). The string
// is statically allocated, use [[strings::dup]] to duplicate it or it will be
// overwritten on subsequent calls.
export fn mode_str(m: mode) const str = {
	static let buf: [10]u8 = [0...];
	buf = [
		(if (m & mode::DIR == mode::DIR) 'd'
			else if (m & mode::FIFO == mode::FIFO) 'p'
			else if (m & mode::SOCK == mode::SOCK) 's'
			else if (m & mode::BLK == mode::BLK) 'b'
			else if (m & mode::LINK == mode::LINK) 'l'
			else if (m & mode::CHR == mode::CHR) 'c'
			else '-'): u8,
		(if (m & mode::USER_R == mode::USER_R) 'r' else '-'): u8,
		(if (m & mode::USER_W == mode::USER_W) 'w' else '-'): u8,
		(if (m & mode::SETUID == mode::SETUID) 's'
			else if (m & mode::USER_X == mode::USER_X) 'x'
			else '-'): u8,
		(if (m & mode::GROUP_R == mode::GROUP_R) 'r' else '-'): u8,
		(if (m & mode::GROUP_W == mode::GROUP_W) 'w' else '-'): u8,
		(if (m & mode::SETGID == mode::SETGID) 's'
			else if (m & mode::GROUP_X == mode::GROUP_X) 'x'
			else '-'): u8,
		(if (m & mode::OTHER_R == mode::OTHER_R) 'r' else '-'): u8,
		(if (m & mode::OTHER_W == mode::OTHER_W) 'w' else '-'): u8,
		(if (m & mode::STICKY == mode::STICKY) 't'
			else if (m & mode::OTHER_X == mode::OTHER_X) 'x'
			else '-'): u8,
	];
	return strings::fromutf8(buf)!;
};

// Returns the permission bits of a file mode.
export fn mode_perm(m: mode) mode = (m: uint & 0o777u): mode;

// Returns the type bits of a file mode.
export fn mode_type(m: mode) mode = (m: uint & ~0o777u): mode;

// bit mask for the file type bit field
def IFMT: mode = 0o0170000u: mode;

// Returns true if this item is a regular file.
export fn isfile(mode: mode) bool = mode & IFMT == mode::REG;

// Returns true if this item is a FIFO (named pipe).
export fn isfifo(mode: mode) bool = mode & IFMT == mode::FIFO;

// Returns true if this item is a directory.
export fn isdir(mode: mode) bool = mode & IFMT == mode::DIR;

// Returns true if this item is a character device.
export fn ischdev(mode: mode) bool = mode & IFMT == mode::CHR;

// Returns true if this item is a block device.
export fn isblockdev(mode: mode) bool = mode & IFMT == mode::BLK;

// Returns true if this item is a symbolic link.
export fn islink(mode: mode) bool = mode & IFMT == mode::LINK;

// Returns true if this item is a Unix socket.
export fn issocket(mode: mode) bool = mode & IFMT == mode::SOCK;
