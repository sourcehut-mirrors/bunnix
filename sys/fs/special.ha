use dev::block;
use dev::chr;
use errors::{error, errno};
use io;

// Opens a character device file.
export fn openchr(
	rdev: u64,
	inode: nullable *io::inode = null,
) (*io::file | error) = {
	const major = (rdev >> 32): u32;
	const minor = rdev: u32;
	let file = chr::open(major, minor)?;
	file.inode = inode;
	return file;
};

// Opens a block device file.
export fn openblk(
	rdev: u64,
	inode: nullable *io::inode = null,
) (*io::file | error) = {
	const major = (rdev >> 32): u32;
	const minor = rdev: u32;
	const bdev = block::opendev(major, minor)?;
	let file = block::openfile(bdev);
	file.inode = inode;
	return file;
};
