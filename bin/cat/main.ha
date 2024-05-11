use fmt;
use fs;
use getopt;
use io;
use os;

export fn main() void = {
	const cmd = getopt::parse(os::args,
		('u', "POSIX compatibility, ignored"),
		"[file...]");
	defer getopt::finish(&cmd);

	if (len(cmd.args) == 0) {
		match (io::copy(os::stdout, os::stdin)) {
		case size => void;
		case let err: io::error =>
			fmt::fatal(io::strerror(err));
		};
		return;
	};

	for (let i = 0z; i < len(cmd.args); i += 1z) {
		const file = open(cmd.args[i]);
		match (io::copy(os::stdout, file)) {
		case size => void;
		case let err: io::error =>
			io::close(file): void;
			fmt::fatal(io::strerror(err));
		};
		io::close(file)!;
	};
};

fn open(path: str) io::handle = {
	if (path == "-") {
		return os::stdin;
	};

	match (os::open(path)) {
	case let err: fs::error =>
		fmt::fatalf("Error opening '{}': {}", path, fs::strerror(err));
	case let file: io::file =>
		return file;
	};
};
