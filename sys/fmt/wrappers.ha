// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors::{error, errno};
use io;
use memio;
use strings;

// Formats text for printing and writes it into a heap-allocated string. The
// caller must free the return value.
export fn asprintf(fmt: str, args: field...) str = {
	let buf = memio::dynamic();
	assert(fprintf(&buf, fmt, args...) is size);
	return strings::fromutf8_unsafe(memio::buffer(&buf));
};

// Formats text for printing and writes it into a caller supplied buffer. The
// returned string is borrowed from this buffer. Aborts if the buffer isn't
// large enough to hold the formatted text.
export fn bsprintf(buf: []u8, fmt: str, args: field...) str = {
	let sink = memio::fixed(buf);
	let l = fprintf(&sink, fmt, args...)!;
	return strings::fromutf8_unsafe(buf[..l]);
};

// Formats text for printing and writes it to an [[io::file]], followed by a
// line feed.
export fn fprintfln(
	h: *io::file,
	fmt: str,
	args: field...
) (error | size) = fprintf(h, fmt, args...)? + io::write(h, ['\n'])?;

// Formats values for printing using the default format modifiers and writes
// them into a heap-allocated string separated by spaces. The caller must free
// the return value.
export fn asprint(args: formattable...) str = {
	let buf = memio::dynamic();
	assert(fprint(&buf, args...) is size);
	return strings::fromutf8_unsafe(memio::buffer(&buf));
};

// Formats values for printing using the default format modifiers and writes
// them into a caller supplied buffer separated by spaces. The returned string
// is borrowed from this buffer. Aborts if the buffer isn't large enough to hold
// the formatted text.
export fn bsprint(buf: []u8, args: formattable...) str = {
	let sink = memio::fixed(buf);
	let l = fprint(&sink, args...)!;
	return strings::fromutf8_unsafe(buf[..l]);
};

// Formats values for printing using the default format modifiers and writes
// them to an [[io::file]] separated by spaces and followed by a line feed.
export fn fprintln(h: *io::file, args: formattable...) (error | size) =
	fprint(h, args...)? + io::write(h, ['\n'])?;
