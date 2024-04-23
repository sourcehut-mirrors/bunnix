use arch::main;		// link
use boot;
use fs;
use fs::memfs;
use log;
use mman;
use path;
use rt;
use strings;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	mman::init(ctx);

	log::println("Initialize memfs as temporary root");
	const memfs = memfs::new();

	log::println("Exercising memfs a bit");

	log::println("Populating a few entries in root");
	const root = fs::superblock_get_root(memfs);
	fs::inode_mkdir(root, "bin", 0o755)!;
	fs::inode_mkdir(root, "dev", 0o755)!;
	fs::inode_mkdir(root, "etc", 0o755)!;
	const tmp = fs::inode_mkdir(root, "tmp", 0o755)!;

	const testino = fs::inode_create(root, "test", 0o644)!;
	const testfile = fs::inode_open(testino)!;
	fs::file_write(testfile, strings::toutf8("Hello world!\n"))!;

	log::println("Contents of memfs:");
	const rootf = fs::inode_open(root)!;
	for (true) {
		let dent = fs::dirent { ... };
		match (fs::file_readdir(rootf, &dent)!) {
		case fs::EOF => break;
		case void => yield;
		};
		log::printfln(
			"{} {}{} (inode {})",
			fs::mode_str(dent.mode),
			dent.name,
			if (fs::isdir(dent.mode)) "/" else "",
			dent.ino,
		);
	};

	log::println("Contents of /test:");
	fs::file_seek(testfile, 0, fs::whence::SET)!;

	let buf: [1024]u8 = [0...];
	const n = fs::file_read(testfile, buf) as size;
	log::print(strings::fromutf8(buf[..n])!);

	log::println("Creating a nested subtree");
	const foo = fs::inode_mkdir(tmp, "foo", 0o755)!;
	const bar = fs::inode_mkdir(foo, "bar", 0o755)!;
	const baz = fs::inode_create(bar, "baz", 0o644)!;
	const bazfile = fs::inode_open(baz)!;
	fs::file_write(bazfile, strings::toutf8("Hello /tmp/foo/bar/baz!\n"))!;

	log::println("Exercising inode_walk...");
	const path = path::init("tmp/foo/bar/baz")!;
	const iter = path::iter(&path);

	const target = fs::inode_walk(root, &iter)!;
	const bazfile = fs::inode_open(target)!;
	log::printfln("Contents of /tmp/foo/bar/baz:");
	const n = fs::file_read(bazfile, buf) as size;
	log::print(strings::fromutf8(buf[..n])!);

	log::println("Everything looks good");

	log::println("Nothing to do; idling");
	rt::halt();
};
