use fs;
use errors::{error, errno};

export type file = struct {
	fs::file,
	pos: size,
};

fn mkfile(ino: *inode) (*fs::file | error) = {
	const impl =
		if (fs::isfile(ino.mode)) {
			yield &file_impl_reg;
		} else if (fs::isdir(ino.mode)) {
			yield &file_impl_dir;
		} else {
			return errno::NOTSUP;
		};
	return alloc(file {
		impl = impl,
		inode = ino,
		...
	});
};
