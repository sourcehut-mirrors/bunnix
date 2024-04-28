// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use encoding::utf8;
use errors::{error, errno};
use io;

// Reads a rune from a UTF-8 file.
export fn read_rune(
	file: *io::file,
) (rune | utf8::invalid | io::EOF | error) = {
	let b: [4]u8 = [0...];
	match (io::readall(file, b[..1])?) {
	case let n: size => void;
	case io::EOF =>
		return io::EOF;
	};

	const sz = utf8::utf8sz(b[0])?;

	if (sz == 1) {
		return b[0]: rune;
	};

	match (io::readall(file, b[1..sz])) {
	case let n: size => void;
	case io::EOF =>
		return io::EOF;
	case let err: error =>
		if (err: errno == errno::UNDERFLOW) {
			return utf8::invalid;
		};
		return err;
	};

	let dec = utf8::decode(b[..sz]);
	match (utf8::next(&dec)?) {
	case let r: rune =>
		return r;
	case void =>
		return io::EOF;
	case utf8::more =>
		return utf8::invalid;
	};
};
