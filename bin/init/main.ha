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

	let buf: [4096]u8 = [0...];
	fmt::println("open /dev/null")!;
	const dnull = os::open("/dev/null")!;
	fmt::print("read: ")!;
	const is_eof = io::read(dnull, buf)! is io::EOF;
	assert(is_eof);
	fmt::println("EOF")!;

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
	const file = os::open("/bin/echo")!;
	fmt::printfln("[child] got fd {}", file: int)!;
	fmt::printfln("[child] reading first 128 bytes...")!;

	let buf: [128]u8 = [0...];
	const n = io::read(file, buf)! as size;
	hex::dump(os::stdout, buf[..n])!;

	fmt::println("[child] execve(2) into /bin/echo")!;
	rt::fexecve(file, [
		"/bin/echo",
		"Hello",
		"from",
		"/bin/echo!",
	], [])!;
};
