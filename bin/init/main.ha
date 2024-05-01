use rt;
use fmt;
use os;

export fn main() void = {
	fmt::println("Hello from userspace!")!;
	fmt::printfln("My pid is {}", rt::getpid(): int)!;

	fmt::println("os::args via System-V:")!;
	for (let arg .. os::args) {
		fmt::println(arg)!;
	};

	fmt::println("calling fork...")!;
	let pid = rt::fork()!;
	if (pid == 0) {
		fmt::println("[child] Hello from the child process!")!;
		fmt::printfln("[child] I have pid {}", rt::getpid(): int)!;
		fmt::printfln("[child] My parent's pid is {}", rt::getppid(): int)!;
		fmt::println("[child] execve(2) into /bin/echo")!;
		rt::execve("/bin/echo", [
			"/bin/echo",
			"Hello",
			"from",
			"/bin/echo!",
		], [])!;
	} else {
		fmt::printfln(
			"[parent] Hello from the parent process! The child has pid {}",
			pid: int)!;
	};

	for (true) void;
};
