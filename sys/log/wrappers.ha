// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use fmt;
use io;

const dev::chr::console_file: io::file;

// The string "WARN" (log prefix)
export const WARN: str = "WARN";

// The string "ERR" (log prefix)
export const ERR: str = "ERR";

// Formats text for printing and writes it to the kernel log.
export fn printf(fmt: str, args: fmt::field...) size =
	fmt::fprintf(&dev::chr::console_file, fmt, args...)!;

// Formats text for printing and writes it to the kernel log, followed by a line
// feed.
export fn printfln(fmt: str, args: fmt::field...) size =
	fmt::fprintfln(&dev::chr::console_file, fmt, args...)!;

// Formats values for printing using the default format modifiers and writes
// them to the kernel log, separated by spaces.
export fn print(args: fmt::formattable...) size =
	fmt::fprint(&dev::chr::console_file, args...)!;

// Formats values for printing using the default format modifiers and writes
// them to the kernel log, separated by spaces and followed by a line feed.
export fn println(args: fmt::formattable...) size =
	fmt::fprintln(&dev::chr::console_file, args...)!;

// Formats text for printing and writes it to the kernel log, followed by a line
// feed.
export fn kprintf(subsys: str, fmt: str, args: fmt::field...) size = {
	const z = printf("[{:-6}] ", subsys);
	z += fmt::fprintf(&dev::chr::console_file, fmt, args...)!;
	return z;
};

// Formats text for printing and writes it to the kernel log, followed by a line
// feed.
export fn kprintfln(subsys: str, fmt: str, args: fmt::field...) size = {
	const z = printf("[{:-6}] ", subsys);
	z += fmt::fprintfln(&dev::chr::console_file, fmt, args...)!;
	return z;
};

// Formats values for printing using the default format modifiers and writes
// them to the kernel log, separated by spaces and followed by a line feed.
export fn kprintln(subsys: str, args: fmt::formattable...) size = {
	const z = printf("[{:-6}] ", subsys);
	z += fmt::fprintln(&dev::chr::console_file, args...)!;
	return z;
};
