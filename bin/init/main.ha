use fmt;
use os;
use os::exec;

export fn main() void = {
	fmt::print("Userspace args: ")!;
	for (let arg .. os::args) {
		fmt::printf("{} ", arg)!;
	};
	fmt::println()!;

	fmt::println("exec /bin/env FOO=bar BAR=baz /bin/env")!;
	const cmd = exec::cmd("/bin/env", "FOO=bar", "BAR=baz", "/bin/env")!;
	const proc = exec::start(&cmd)!;
	const st = exec::wait(&proc)!;
	const exit = exec::exit(&st);
	fmt::printfln("[parent] child pid {}: {}",
		proc: int, exec::exitstr(exit))!;

	for (true) void;
};
