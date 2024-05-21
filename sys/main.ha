use arch::main;		// link
use blibc;		// link
use uapi;		// link
use arch;
use boot;
use dev;
use dev::block;
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

let vroot = fs::vfs {
	root = null: *io::inode,
	...
};

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	// Initialize subsystems
	mman::init(ctx);
	arch::init();

	// Scan for devices
	dev::scan();

	// System startup
	const cmdline =
		if (ctx.cmdline == "") "/bunnix"
		else ctx.cmdline;

	const args = match (shlex::split(cmdline)) {
	case let s: []str =>
		yield s;
	case shlex::syntaxerr =>
		log::kprintln(KERN, "Unable to parse kernel command line");
		rt::halt();
	};
	defer strings::freeall(args);

	let root_opts = fs::fs_opts {
		fstype = "ext4",
		...
	};
	let init = "/sbin/init";
	for (let i = 0z; i < len(args); i += 1) {
		const (key, val) = strings::cut(args[i], "=");
		switch (key) {
		case "root" =>
			// Don't mount root if there is an initramfs
			if (len(ctx.mods) != 0) yield;

			match (block::open(val)) {
			case let bdev: *block::blockdev =>
				root_opts.device = bdev;
			case let err: error =>
				log::printfln("Error opening root device: {}",
					strerror(err));
				rt::halt();
			};
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
	const root = if (len(ctx.mods) == 0) {
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
		yield fs::mount_root(&vroot, fs);
	} else {
		yield mount_initrd(&vroot, &ctx.mods[0]);
	};

	// Populate /dev
	mountdev(root);

	// Start /sbin/init
	log::kprintfln(KERN, "entering userspace: exec {}", init);
	const proc = proc::new_proc(root, root, "/", null)!;
	const (inode, _) = fs::walk(root, init)!;

	const consdev = dev::mkdev(dev::TTY_ALT_MAJOR, dev::CONS_MINOR);
	const cons = fs::openchr(consdev, 0)!;
	proc::installfd(proc, cons);	// stdin
	proc::installfd(proc, cons);	// stdout
	proc::installfd(proc, cons);	// stderr

	const file = io::inode_open(inode, 0)!;

	args[0] = init;
	match (proc::exec(proc, file, args, [])) {
	case let err: error =>
		log::kprintfln(KERN, "Error loading {}: {}",
			init, strerror(err));
		rt::halt();
	case void => void;
	};

	abort(); // unreachable
};
