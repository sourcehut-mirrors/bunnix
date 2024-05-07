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

	fmt::println("Test pipe(2)")!;
	const (rd, wr) = exec::pipe();
	fmt::printfln("read fd: {}; write fd: {}", rd: int, wr: int)!;

	fmt::println("fork")!;
	match (exec::fork()!) {
	case let proc: exec::process =>
		io::close(rd)!;
		fmt::println("[parent] write to pipe")!;

		fmt::fprintln(wr, "Hello from the parent process!")!;
		io::close(wr)!;

		fmt::println("[parent] wait(child)")!;
		exec::wait(&proc)!;
	case =>
		io::close(wr)!;
		fmt::println("[child] read from pipe:")!;

		io::copy(os::stdout, rd)!;

		fmt::println("[child] exit")!;
		os::exit(0);
	};

	os::chdir("/bin")!;

	fmt::println("[hare] exec test-c")!;
	const cmd = exec::cmd("./test-c", "Hello", "test-c")!;
	const proc = exec::start(&cmd)!;
	const st = exec::wait(&proc)!;
	const exit = exec::exit(&st);
	fmt::printfln("[hare] child (pid {}): {}",
		proc: int, exec::exitstr(exit))!;

	for (true) void;
};
