use dev;
use dev::block;
use fs::memfs;
use fs;
use io;

fn mountdev(root: *io::inode) void = {
	// TODO: We should probably have a devtmpfs thing and deal with
	// hotplugging and such
	const dev = memfs::new();
	fs::mount_fs(root, dev, "/dev")!;
	const devroot = fs::superblock_get_root(dev);
	io::inode_mknod(devroot, "full", 0o666 | io::mode::CHR,
		dev::mkdev(dev::devmajor::MEM, dev::devminor_mem::NOSPC))!;
	io::inode_mknod(devroot, "null", 0o666 | io::mode::CHR,
		dev::mkdev(dev::devmajor::MEM, dev::devminor_mem::NULL))!;
	io::inode_mknod(devroot, "zero", 0o666 | io::mode::CHR,
		dev::mkdev(dev::devmajor::MEM, dev::devminor_mem::ZERO))!;
	block::mknodes(devroot)!;
};
