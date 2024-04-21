// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use fmt;

// Formats text for printing and writes it to the kernel log.
export fn printf(fmt: str, args: fmt::field...) size =
	fmt::fprintf(cons, fmt, args...);

// Formats text for printing and writes it to the kernel log, followed by a line
// feed.
export fn printfln(fmt: str, args: fmt::field...) size =
	fmt::fprintfln(cons, fmt, args...);

// Formats values for printing using the default format modifiers and writes
// them to the kernel log, separated by spaces.
export fn print(args: fmt::formattable...) size =
	fmt::fprint(cons, args...);

// Formats values for printing using the default format modifiers and writes
// them to the kernel log, separated by spaces and followed by a line feed.
export fn println(args: fmt::formattable...) size =
	fmt::fprintln(cons, args...);
