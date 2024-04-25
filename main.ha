use arch::main;		// link
use blibc;		// link
use arch;
use boot;
use dev;
use log;
use mman;
use rt;
// XXX TEMP
use dev::block;
use fs;
use fs::ext4;
use path;

const KERN: str = "kern";

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	// Initialize subsystems
	mman::init(ctx);
	arch::init();

	// Scan for devices
	dev::scan();

	// System startup
	// (TODO)

	const bdev = block::open("sata0b")!;
	const fs = ext4::open(bdev)!;
	const root = fs::superblock_get_root(fs);
	log::printfln("root inode: {} mode 0{:o} uid/gid {}:{} dev {}",
		root, root.mode: uint, root.uid, root.gid, root.dev);
	listdir(root);

	const path = path::init("/bunnix/config.mk")!;
	const iter = path::iter(&path);
	path::nextiter(&iter); // Skip /
	const node = fs::inode_walk(root, &iter)!;

	log::println("Nothing to do; idling");
	rt::halt();
};

fn listdir(inode: *fs::inode) void = {
	const dir = fs::inode_open(inode)!;
	let dent = fs::dirent { ... };
	for (true) {
		match (fs::file_readdir(dir, &dent)!) {
		case void => yield;
		case fs::EOF => break;
		};
		log::printfln("{} {}",
			fs::mode_str(dent.mode),
			dent.name);
	};
};
