use rt;
use fmt;

export fn main() void = {
	fmt::println("Hello from userspace!")!;

	fmt::println("calling fork...")!;
	let pid = rt::fork()!;
	if (pid == 0) {
		fmt::println("Hello from the child process")!;
	} else {
		fmt::println("Hello from the parent process")!;
	};

	for (true) void;
};
