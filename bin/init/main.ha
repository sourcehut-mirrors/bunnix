use fmt;
use fs;
use io;
use os;
use os::exec;
use strings;

export fn main() void = {
	fmt::print("[init] Userspace args: ")!;
	for (let arg .. os::args) {
		fmt::printf("{} ", arg)!;
	};
	fmt::println()!;

	fmt::println("[init] capture stdout of /bin/echo Hello world")!;
	const (rd, wr) = exec::pipe();
	const cmd = exec::cmd("/bin/echo", "Hello world")!;
	exec::addfile(&cmd, os::stdout_file, wr);
	const proc = exec::start(&cmd)!;

	io::close(wr)!;

	const data = io::drain(rd)!;
	defer free(data);
	io::close(rd)!;
	exec::wait(&proc)!;

	const data = strings::fromutf8(data)!;
	fmt::printf("[init] stdout from /bin/echo: {}", data)!;

	fmt::println("[init] exec /bin/test-c")!;
	const cmd = exec::cmd("/bin/test-c", "Hello C")!;
	const proc = exec::start(&cmd)!;
	const st = exec::wait(&proc)!;
	const exit = exec::exit(&st);
	fmt::printfln("[init] child (pid {}): {}",
		proc: int, exec::exitstr(exit))!;

	for (true) void;
};
