use fmt;
use fs;
use io;
use os::exec;
use os;

export fn main() void = {
	fmt::print("[hare] Userspace args: ")!;
	for (let arg .. os::args) {
		fmt::printf("{} ", arg)!;
	};
	fmt::println()!;

	fmt::println("[hare] open /usr/include/stdio.h")!;
	const file = os::open("/usr/include/stdio.h")!;
	fmt::printfln("[hare] fstat {}", file: int)!;
	const stat = os::fstat(file)!;
	fmt::printfln("[hare] mode {} bytes {} owner {}:{}",
		fs::mode_str(stat.mode),
		stat.sz, stat.uid, stat.gid)!;
	io::close(file)!;

	fmt::println("[hare] exec /bin/test-c")!;
	const cmd = exec::cmd("/bin/test-c")!;
	const proc = exec::start(&cmd)!;
	const st = exec::wait(&proc)!;
	const exit = exec::exit(&st);
	fmt::printfln("[hare] child (pid {}): {}",
		proc: int, exec::exitstr(exit))!;

	for (true) void;
};
