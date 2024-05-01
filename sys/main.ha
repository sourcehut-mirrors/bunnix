use arch::main;		// link
use blibc;		// link
use uapi;		// link
use arch;
use boot;
use dev;
use errors::{error, errno, strerror};
use fs;
use io;
use log;
use mman;
use proc;
use rt;
use shlex;
use strings;

const KERN: str = "kern";

let root = fs::vfs { ... };

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	// Initialize subsystems
	mman::init(ctx);
	arch::init();

	// Scan for devices
	dev::scan();

	// System startup
	const args = match (shlex::split(ctx.cmdline)) {
	case let s: []str =>
		yield s;
	case shlex::syntaxerr =>
		log::kprintln(KERN, "Unable to parse kernel command line");
		rt::halt();
	};
	defer strings::freeall(args);

	let root_opts = fs::fs_opts {
		device = "",
		fstype = "ext4",
		...
	};
	let init = "/bin/init";
	for (let i = 0z; i < len(args); i += 1) {
		const (key, val) = strings::cut(args[i], "=");
		switch (key) {
		case "root" =>
			root_opts.device = val;
		case "rootfstype" =>
			root_opts.fstype = val;
		case "ro" =>
			root_opts.readonly = true;
		case "init" =>
			init = val;
		case => void;
		};
	};

	// Mount root
	log::kprintfln(KERN, "Mount root from {} as {}",
		root_opts.device, root_opts.fstype);
	const fs = match (fs::fs_open(&root_opts)) {
	case let fs: *fs::superblock =>
		yield fs;
	case let err: error =>
		log::kprintfln(KERN, "Error mounting root filesystem: {}",
			strerror(err));
		rt::halt();
	};
	fs::mount_root(&root, fs);

	// Start /bin/init
	log::kprintfln(KERN, "entering userspace: exec {}", init);
	const proc = proc::new_proc(&root, null)!;
	const (inode, _) = fs::walk(&root, init)!;

	// TODO: Implement console device properly, i.e. /dev/cons
	proc::appendfd(proc, log::cons);	// stdin
	proc::appendfd(proc, log::cons);	// stdout
	proc::appendfd(proc, log::cons);	// stderr

	const file = io::inode_open(inode)!;

	match (proc::exec(proc, file, [init], [])) {
	case let err: error =>
		log::kprintfln(KERN, "Error loading {}: {}",
			init, strerror(err));
		rt::halt();
	case void => void;
	};

	abort(); // unreachable
};
