use fmt;
use os::exec;

export fn main() void = {
	fmt::println("Hello from userspace!")!;

	fmt::println("exec /bin/env FOO=bar BAR=baz /bin/env")!;
	const cmd = exec::cmd("/bin/env", "FOO=bar", "BAR=baz", "/bin/env")!;
	const proc = exec::start(&cmd)!;
	const st = exec::wait(&proc)!;
	const exit = exec::exit(&st);
	fmt::printfln("[parent] child pid {}: {}",
		proc: int, exec::exitstr(exit))!;

	for (true) void;
};
