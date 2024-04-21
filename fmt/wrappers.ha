// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use cons;

// Formats text for printing and writes it to an [[io::handle]], followed by a
// line feed.
export fn fprintfln(
	h: *cons::console,
	fmt: str,
	args: field...
) size = fprintf(h, fmt, args...) + cons::write(h, ['\n']);

// Formats values for printing using the default format modifiers and writes
// them to an [[io::handle]] separated by spaces and followed by a line feed.
export fn fprintln(h: *cons::console, args: formattable...) size =
	fprint(h, args...) + cons::write(h, ['\n']);
