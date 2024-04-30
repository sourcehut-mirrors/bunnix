use rt;
use fmt;
use os;

export fn main() void = {
	fmt::println("Hello from userspace!")!;

	fmt::println("os::args via System-V:")!;
	for (let arg .. os::args) {
		fmt::println(arg)!;
	};

	fmt::println("calling fork...")!;
	let pid = rt::fork()!;
	if (pid == 0) {
		fmt::println("Hello from the child process!")!;
		fmt::println("execve(2) into /bin/echo")!;
		rt::execve("/bin/echo", [
			"/bin/echo",
			"Hello",
			"from",
			"/bin/echo!",
		], [])!;
	} else {
		fmt::printfln(
			"Hello from the parent process! The child has pid {}",
			pid: int)!;
	};

	for (true) void;
};
