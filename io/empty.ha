// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};

const _empty_vt: vtable = vtable {
	reader = &empty_read,
	writer = &empty_write,
	...
};

// Static global [[io::empty]].
export const static_empty: stream = &_empty_vt;

// A [[stream]] which always reads EOF and discards any writes.
export const empty: *stream = &static_empty;

fn empty_read(s: *stream, buf: []u8) (size | EOF | error) = EOF;

fn empty_write(s: *stream, buf: const []u8) (size | error) = len(buf);
