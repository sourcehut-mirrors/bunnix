use dev::chr;
use dev::block;
use io;
use errors::{error, errno};
use log;

export type file = struct {
	io::file,
	pos: size,
};

fn mkfile(ino: *inode) (*io::file | error) = {
	const impl =
		if (io::isfile(ino.mode)) {
			yield &file_impl_reg;
		} else if (io::isdir(ino.mode)) {
			yield &file_impl_dir;
		} else if (io::ischdev(ino.mode)) {
			const major = (ino.rdev >> 32): u32;
			const minor = ino.rdev: u32;
			return chr::open(major, minor);
		} else if (io::isblockdev(ino.mode)) {
			const major = (ino.rdev >> 32): u32;
			const minor = ino.rdev: u32;
			return block::opendev(major, minor);
		} else {
			return errno::NOTSUP;
		};
	return alloc(file {
		vtable = impl,
		inode = ino,
		...
	});
};

fn file_finish(file: *io::file) void = {
	free(file);
};
