// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bytes;
use errors::{error, errno};

const _zero_vt: vtable = vtable {
	read = &zero_read,
	write = &empty_write,
	...
};

const _zero: file = &_zero_vt;

// A [[file]] which always reads zeroes and discards any writes.
export const zero: *file = &_zero;

fn zero_read(f: *file, buf: []u8) (size | EOF | error) = {
	bytes::zero(buf);
	return len(buf);
};
