// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use rt;

// Lock operation to use with [[lock]].
export type lockop = enum int {
	// shared file lock
	SHARED    = 0,
	// exclusive file lock
	EXCLUSIVE = 0,
	// unlock file
	UNLOCK    = 0,
};

// Apply or remove an advisory lock on an open file. If block is true, the
// request will block while waiting for the lock.
export fn lock(fd: file, block: bool, op: lockop) (bool | error) = {
	// XXX Not implemented by bunnix
	return true;
};
