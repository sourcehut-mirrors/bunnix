use io;
use errors::{error, errno};

export type file = struct {
	io::file,
	inode: *inode,
	pos: size,
};

fn mkfile(ino: *inode) (*io::file | error) = {
	const impl =
		if (io::isfile(ino.mode)) {
			yield &file_impl_reg;
		} else if (io::isdir(ino.mode)) {
			yield &file_impl_dir;
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
