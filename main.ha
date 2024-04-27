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
use fs::memfs;
use path;
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
	// (TODO)

	log::kprintln(KERN, "Mount root from sata0b as ext4");
	const bdev = block::open("sata0b")!;
	const fs = ext4::open(bdev)!;
	fs::mount_root(&root, fs);

	const dir = fs::walk(&root, "/bin")!;
	listdir(dir);

	log::println("First 128 bytes of /bin/init:");
	const node = fs::walk(&root, "/bin/init")!;
	const file = fs::inode_open(node)!;
	let buf: [128]u8 = [0...];
	const n = fs::file_read(file, buf) as size;
	log::dump(buf[..n]);

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
		log::printfln("{} {}{}",
			fs::mode_str(dent.mode),
			dent.name,
			if (fs::isdir(dent.mode)) "/" else "");
	};
};
