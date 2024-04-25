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

	log::kprintln(KERN, "Mount /tmp from memfs");
	const tmpfs = memfs::new();
	fs::mount_fs(&root, tmpfs, "/tmp")!;

	const dir = fs::walk(&root, "/")!;
	log::printfln("root inode: {} mode 0{:o} uid/gid {}:{} dev {}",
		dir, dir.mode: uint, dir.uid, dir.gid, dir.dev);
	listdir(dir);

	log::println("First 128 bytes of /bunnix/config.mk:");
	const node = fs::walk(&root, "/bunnix/config.mk")!;
	const file = fs::inode_open(node)!;
	let buf: [128]u8 = [0...];
	const n = fs::file_read(file, buf) as size;
	log::println(strings::fromutf8_unsafe(buf[..n]));

	log::println("Making test file in /tmp");
	const tmp = fs::superblock_get_root(tmpfs);
	const file = fs::inode_create(tmp, "example", 0o644)!;
	const file = fs::inode_open(file)!;
	fs::file_write(file, strings::toutf8("Hello world!\n"))!;

	log::println("Contents of /tmp/example:");
	const node = fs::walk(&root, "/tmp/example")!;
	const file = fs::inode_open(node)!;
	let buf: [128]u8 = [0...];
	const n = fs::file_read(file, buf) as size;
	log::print(strings::fromutf8_unsafe(buf[..n]));

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
