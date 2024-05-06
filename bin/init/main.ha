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

	fmt::println("stat /usr/include/stdio.h")!;
	const st = os::stat("/usr/include/stdio.h")!;
	fmt::printfln("mode {:o}/{} owner {}:{} size {} bytes",
		st.mode: uint, fs::mode_str(st.mode), st.uid, st.gid, st.sz)!;

	fmt::println("[hare] exec /bin/test-c")!;
	const cmd = exec::cmd("/bin/test-c", "Hello", "test-c")!;
	const proc = exec::start(&cmd)!;
	const st = exec::wait(&proc)!;
	const exit = exec::exit(&st);
	fmt::printfln("[hare] child (pid {}): {}",
		proc: int, exec::exitstr(exit))!;

	for (true) void;
};
