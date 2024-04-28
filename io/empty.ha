// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};

const _empty_vt: vtable = vtable {
	read = &empty_read,
	write = &empty_write,
	...
};

// Static global [[io::empty]].
export const static_empty: file = &_empty_vt;

// A [[file]] which always reads EOF and discards any writes.
export const empty: *file = &static_empty;

fn empty_read(s: *file, buf: []u8) (size | EOF | error) = EOF;

fn empty_write(s: *file, buf: const []u8) (size | error) = len(buf);
