// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use encoding::utf8;
use io;
use errors::{error, errno};

// Appends a rune to a file.
export fn appendrune(out: *io::file, r: rune) (size | error) =
	io::writeall(out, utf8::encoderune(r));
