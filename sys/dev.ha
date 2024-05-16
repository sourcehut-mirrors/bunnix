use dev;
use dev::chr;
use dev::block;
use fs::memfs;
use fs;
use io;

fn mountdev(root: *io::inode) void = {
	// TODO: We should probably have a devtmpfs thing and deal with
	// hotplugging and such
	const dev = memfs::new();
	fs::mount_fs(root, dev, "/dev")!;

	// Character devices
	const devroot = fs::superblock_get_root(dev);
	io::inode_mknod(devroot, "full", 0o666 | io::mode::CHR,
		dev::mkdev(dev::MEM_MAJOR, dev::NOSPC_MINOR))!;
	io::inode_mknod(devroot, "null", 0o666 | io::mode::CHR,
		dev::mkdev(dev::MEM_MAJOR, dev::NULL_MINOR))!;
	io::inode_mknod(devroot, "zero", 0o666 | io::mode::CHR,
		dev::mkdev(dev::MEM_MAJOR, dev::ZERO_MINOR))!;
	io::inode_mknod(devroot, "cons", 0o220 | io::mode::CHR,
		dev::mkdev(dev::TTY_ALT_MAJOR, dev::CONS_MINOR))!;

	// dev/kbd, if available
	if (chr::lookup(dev::INPUT_MAJOR, dev::KBD_MINOR) is *chr::chardev) {
		io::inode_mknod(devroot, "kbd", 0o660 | io::mode::CHR,
			dev::mkdev(dev::INPUT_MAJOR, dev::KBD_MINOR))!;
	};

	// TTY devices
	chr::mounttty(devroot);

	// Framebuffer devices
	chr::mountfb(devroot);

	// Block devices
	block::mknodes(devroot)!;
};
