// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};

// Copies data from one *stream into another. If reading from the source file
// returns zero (underread), the copy is terminated and the amount of data
// copied is returned. Note that this function will never return if the source
// *stream is infinite.
export fn copy(dest: *stream, src: *stream) (size | error) = {
	let w = 0z;
	let buf: [4096]u8 = [0...];
	for (let n => read(src, buf[..])?) {
		w += writeall(dest, buf[..n])?;
	};
	return w;
};
