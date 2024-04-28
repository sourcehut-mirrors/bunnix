use io;
use errors::{error, errno};
use lib::lwext4;

export type file = struct {
	impl: io::file,
	inode: *inode,
	union {
		diter: lwext4::dir_iter,
		lwfile: lwext4::file,
	},
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
	const f = alloc(file {
		impl = impl,
		inode = ino,
		...
	});
	return f;
};
