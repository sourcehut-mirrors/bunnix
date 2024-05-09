use fmt;
use fs;
use io;
use os;
use os::exec;
use strings;

export fn main() void = {
	fmt::println("[init] exec /etc/rc")!;
	// TODO: exec directly via shebang
	const cmd = exec::cmd("/bin/sh", "-x", "/etc/rc")!;
	const proc = exec::start(&cmd)!;

	// TODO: reap children and handle signals

	for (true) void;
};
