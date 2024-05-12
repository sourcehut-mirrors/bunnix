use bufio;
use fmt;
use fs;
use getopt;
use io;
use os;
use os::exec;
use unix::passwd;

export fn main() void = {
	const help: []getopt::help = [
		"begins a session on a TTY device",
		"tty [term [cmd [args...]]]",
	];
	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);
	if (len(cmd.args) < 1) {
		getopt::printusage(os::stderr, "getty", help)!;
		os::exit(1);
	};

	def OFLAG = fs::flag::RDWR | fs::flag::CTTY;
	const tty = match (os::open(cmd.args[0], OFLAG)) {
	case let tty: io::file =>
		yield tty;
	case let err: fs::error =>
		fmt::fatalf("Error opening tty {}: {}",
			cmd.args[0], fs::strerror(err));
	};

	io::dup2(tty, os::stdin_file, io::dupflag::NOCLOEXEC)!;
	io::dup2(tty, os::stdout_file, io::dupflag::NOCLOEXEC)!;
	io::dup2(tty, os::stderr_file, io::dupflag::NOCLOEXEC)!;

	let scan = bufio::newscanner(os::stdin);
	defer bufio::finish(&scan);

	let logname = "";
	for (true) {
		fmt::print("bunnix login: ")!;
		bufio::flush(os::stdout)!;

		match (bufio::scan_line(&scan)) {
		case let name: const str =>
			logname = name;
		case let err: io::error =>
			fmt::fatal("Error reading from tty:", io::strerror(err));
		case => abort();
		};

		match (passwd::getuser(logname)) {
		case let pw: passwd::pwent =>
			passwd::pwent_finish(&pw);
			break;
		case void =>
			fmt::println("No such login")!;
		};
	};

	os::setenv("TERM", "bunnix")!;

	// TODO: call /bin/login
	const cmd = match (exec::cmd("/bin/sh")) {
	case let err: exec::error =>
		fmt::fatal("Error executing /bin/login:", exec::strerror(err));
	case let cmd: exec::command =>
		yield cmd;
	};
	exec::exec(&cmd);
};
