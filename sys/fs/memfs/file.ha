use fs;
use io;
use errors::{error, errno};
use log;

export type file = struct {
	io::file,
	pos: size,
};

fn mkfile(ino: *inode, flag: io::flag) (*io::file | error) = {
	const impl =
		if (io::isfile(ino.mode)) {
			yield &file_impl_reg;
		} else if (io::isdir(ino.mode)) {
			yield &file_impl_dir;
		} else if (io::ischdev(ino.mode)) {
			return fs::openchr(ino.rdev, flag, ino)?;
		} else if (io::isblockdev(ino.mode)) {
			return fs::openblk(ino.rdev, flag, ino)?;
		} else {
			return errno::NOTSUP;
		};
	return alloc(file {
		vtable = impl,
		inode = ino,
		flag = flag,
		...
	})!;
};

fn file_finish(file: *io::file) void = {
	free(file);
};
