use fmt;
use getopt;
use os;
use rt;
use strings;

export fn main() void = {
	const help: []getopt::help = [
		"mounts a filesystem",
		('t', "type", "filesystem type"),
		('o', "opts", "options list, comma separated"),
		"<device> <dir>",
	];
	fmt::println("mount(1) parse options")!;
	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);

	if (len(cmd.args) != 2) {
		getopt::printusage(os::stderr, "mount", help)!;
		os::exit(1);
	};

	// TODO: Probe filesystem type
	let fstype = "ext4";
	let misc: []str = [];
	for (let (opt, val) .. cmd.opts) {
		switch (opt) {
		case 't' =>
			fstype = val;
		case 'o' =>
			misc = strings::split(val, ",");
		case => abort();
		};
	};

	let opts = rt::mount_options {
		device = cmd.args[0],
		mountpoint = cmd.args[1],
		fstype = fstype,
		misc = misc,
		...
	};
	match (rt::mount(&opts)) {
	case let err: rt::errno =>
		fmt::fatal(rt::strerror(err));
	case void => void;
	};
};
