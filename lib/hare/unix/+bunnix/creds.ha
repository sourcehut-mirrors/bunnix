// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>
// Unix credentials types & functions; ref credentials(7)

use errors;
use rt;

// Process ID.
export type pid = rt::pid_t;

// User ID.
export type uid = rt::uid_t;

// Group ID.
export type gid = rt::gid_t;

// Returns the current process user ID.
export fn getuid() uid = {
	return rt::getuid();
};

// Returns the current process effective user ID.
export fn geteuid() uid = {
	return rt::geteuid();
};

// Returns the current process group ID.
export fn getgid() gid = {
	return rt::getgid();
};

// Returns the current process effective group ID.
export fn getegid() gid = {
	return rt::getegid();
};

// Returns a list of supplementary group IDs for the current process. The
// returned slice is statically allocated.
export fn getgroups() []gid = {
	static let gids: [rt::NGROUPS_MAX]rt::gid_t = [0...];
	let creds = rt::creds { ... };
	creds.groups = gids;
	rt::getcreds(&creds);
	return creds.groups[..creds.ngroup]: []gid;
};

// Returns the current process ID.
export fn getpid() pid = rt::getpid();

// Returns the parent process ID.
export fn getppid() pid = rt::getppid();

// Returns the current process group ID.
export fn getpgrp() pid = rt::getpgid();

// Returns the current process's session ID.
export fn getsid() pid = rt::getsid();
