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

// Returns the current process ID.
export fn getpid() pid = rt::getpid();

// Returns the parent process ID.
export fn getppid() pid = rt::getppid();
