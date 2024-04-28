use io;
use errors::{error, errno};
use lib::lwext4;

export type file = struct {
	io::file,
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
		vtable = impl,
		inode = ino,
		...
	});
	return f;
};

fn file_finish(fd: *io::file) void = {
	let file = fd: *file;
	if (io::isdir(file.inode.mode)) {
		lwext4::dir_iterator_fini(&file.diter);
	} else {
		lwext4::fclose(&file.lwfile);
	};
	free(file);
};
