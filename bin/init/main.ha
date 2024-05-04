use fmt;
use fs;
use io;
use os;
use os::exec;
use strings;
use unix;

export fn main() void = {
	fmt::println("Hello from userspace!")!;
	fmt::printfln("My pid is {}", unix::getpid(): int)!;

	fmt::println("calling fork...")!;

	const child = match (exec::fork()!) {
	case let proc: exec::process =>
		yield proc;
	case void =>
		child();
	};

	fmt::printfln("[parent] calling waitpid")!;
	const st = exec::wait(&child)!;
	const exit = exec::exit(&st);
	fmt::printfln("[parent] child {}: {}",
		child: int, exec::exitstr(exit))!;

	for (true) void;
};

fn child() never = {
	fmt::println("[child] Hello from the child process!")!;
	fmt::printfln("[child] I have pid {}", unix::getpid(): int)!;
	fmt::printfln("[child] My parent's pid is {}", unix::getppid(): int)!;

	fmt::println("[child] open /bin/echo to test userspace filesystem access")!;

	fmt::println("[child] execve(2) into /bin/echo")!;
	const cmd = exec::cmd("/bin/echo", "Hello", "from", "/bin/echo")!;
	exec::exec(&cmd);
};
