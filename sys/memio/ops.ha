// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use encoding::utf8;
use io;
use errors::{error, errno};
use strings;

// Appends a rune to a file.
export fn appendrune(out: *io::file, r: rune) (size | error) =
	io::writeall(out, utf8::encoderune(r));

// Joins several strings together by a delimiter and writes them to a handle.
// The output needn't be a memio stream, but it's generally more efficient if it
// is. Returns the number of bytes written, or an error.
export fn join(out: *io::file, delim: str, strs: str...) (size | error) = {
	let n = 0z;
	let delim = strings::toutf8(delim);
	for (let i = 0z; i < len(strs); i += 1) {
		n += io::writeall(out, strings::toutf8(strs[i]))?;
		if (len(delim) != 0 && i + 1 < len(strs)) {
			n += io::writeall(out, delim)?;
		};
	};
	return n;
};
