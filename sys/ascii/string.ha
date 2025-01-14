// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use encoding::utf8;
use strings;

// Converts all ASCII uppercase characters in a string to their lowercase
// representation, returning a new string. The return value must be freed by the
// caller.
export fn strlower(s: str) str = {
	let new: []u8 = alloc([], len(s))!;
	return strlower_buf(s, new);
};

// Converts all ASCII uppercase characters in a string to their lowercase
// representation, returning a new string. The new string data is stored in the
// supplied buffer. This function will abort if the buffer's length is too small
// to fit the entire string.
export fn strlower_buf(s: str, buf: []u8) str = {
	let it = strings::iter(s);
	for (let r => strings::next(&it)) {
		static append(buf, utf8::encoderune(tolower(r))...)!;
	};
	return strings::fromutf8(buf)!;
};

// Converts all ASCII lowercase characters in a string to their uppercase
// representation, returning a new string. The return value must be freed by the
// caller.
export fn strupper(s: str) str = {
	let new: []u8 = alloc([], len(s))!;
	return strupper_buf(s, new);
};

// Converts all ASCII lowercase characters in a string to their uppercase
// representation, returning a new string. The new string data is stored in the
// supplied buffer. This function will abort if the buffer's length is too small
// to fit the entire string.
export fn strupper_buf(s: str, buf: []u8) str = {
	let it = strings::iter(s);
	for (let r => strings::next(&it)) {
		static append(buf, utf8::encoderune(toupper(r))...)!;
	};
	return strings::fromutf8(buf)!;
};
