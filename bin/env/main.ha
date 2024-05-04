use errors;
use fmt;
use getopt;
use os::exec;
use os;
use strings;

export fn main() void = {
	const help: []getopt::help = [
		"set the environment for command invocation",
		('i', "ignore the parent environment"),
		"[command [arguments...]]",
	];
	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);

	let clear = false;
	for (let i = 0z; i < len(cmd.opts); i += 1) {
		switch (cmd.opts[i].0) {
		case 'i' =>
			clear = true;
		case => void;
		};
	};

	let environ: []str = cmd.args, args: []str = [];
	for (let i = 0z; i < len(cmd.args); i += 1) {
		if (!strings::contains(cmd.args[i], '=')) {
			environ = cmd.args[..i];
			args = cmd.args[i..];
			break;
		};
	};

	if (len(args) == 0) {
		printenv(environ, clear);
		return;
	};

	let cmd = match (exec::cmd(args[0], args[1..]...)) {
	case let cmd: exec::command =>
		yield cmd;
	case exec::nocmd =>
		fmt::errorfln("{}: command not found", args[0])!;
		os::exit(127);
	case let err: exec::error =>
		fmt::fatalf("exec: {}", exec::strerror(err));
	};
	if (clear) {
		exec::clearenv(&cmd);
	};
	for (let i = 0z; i < len(environ); i += 1) {
		let env = strings::cut(environ[i], "=");
		match (exec::setenv(&cmd, env.0, env.1)) {
		case errors::invalid =>
			fmt::fatalf("Error: Invalid key '{}'", env.0);
		case void => void;
		};
	};
	exec::exec(&cmd);
};

fn printenv(environ: []str, clear: bool) void = {
	if (!clear) {
		printenv(os::getenvs(), true);
	};
	for (let i = 0z; i < len(environ); i += 1) {
		fmt::println(environ[i])!;
	};
};
