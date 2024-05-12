use dev::block;
use dev::chr;
use errors::{error, errno};
use io;

// Opens a character device file.
export fn openchr(rdev: u64) (*io::file | error) = {
	const major = (rdev >> 32): u32;
	const minor = rdev: u32;
	return chr::open(major, minor);
};

// Opens a block device file.
export fn openblk(rdev: u64) (*io::file | error) = {
	const major = (rdev >> 32): u32;
	const minor = rdev: u32;
	const bdev = block::opendev(major, minor)?;
	return block::openfile(bdev);
};
