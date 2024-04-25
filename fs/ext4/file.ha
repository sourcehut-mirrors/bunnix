use fs;
use errors::{error, errno};
use lib::lwext4;

export type file = struct {
	fs::file,
	union {
		diter: lwext4::dir_iter,
	},
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
