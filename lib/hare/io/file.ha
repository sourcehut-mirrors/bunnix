// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

// Truncate a file to a specified length. The file must be open for writing.
export fn trunc(fd: file, ln: size) (void | error) = fd_trunc(fd, ln);
