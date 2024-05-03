use encoding::hex;
use fmt;
use fs;
use io;
use os;
use rt;
use strings;

export fn main() void = {
	fmt::println("Hello from userspace!")!;
	fmt::printfln("My pid is {}", rt::getpid(): int)!;

	fmt::println("os::args via System-V:")!;
	for (let arg .. os::args) {
		fmt::println(arg)!;
	};

	fmt::println("Contents of /dev:")!;
	const iter = os::iter("/dev")!;
	for (let dent => fs::next(iter)!) {
		fmt::printfln("{}\t{}{}",
			fs::mode_str(dent.ftype),
			dent.name,
			if (fs::isdir(dent.ftype)) "/" else "")!;
	};
	fs::finish(iter);

	fmt::println("Create /etc/hello")!;
	const file = os::create("/etc/hello", 0o644)!;
	fmt::fprintln(file, "Hello world!")!;
	io::close(file)!;

	fmt::println("mkdir /foobar")!;
	os::mkdir("/foobar", 0o755)!;

	fmt::println("calling fork...")!;
	let pid = rt::fork()!;
	if (pid == 0) {
		child();
	} else {
		fmt::printfln(
			"[parent] Hello from the parent process! The child has pid {}",
			pid: int)!;
	};

	for (true) void;
};

fn child() void = {
	fmt::println("[child] Hello from the child process!")!;
	fmt::printfln("[child] I have pid {}", rt::getpid(): int)!;
	fmt::printfln("[child] My parent's pid is {}", rt::getppid(): int)!;

	fmt::println("[child] open /bin/echo to test userspace filesystem access")!;

	fmt::println("[child] execve(2) into /bin/echo")!;
	rt::execve("/bin/echo", [
		"/bin/echo",
		"Hello",
		"from",
		"/bin/echo!",
	], [])!;
};
