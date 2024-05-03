use dev::chr;
use dev::block;
use io;
use errors::{error, errno};
use lib::lwext4;

export type file = struct {
	io::file,
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
	const f = alloc(file {
		vtable = impl,
		inode = ino,
		...
	});
	return f;
};

fn file_finish(fd: *io::file) void = {
	let file = fd: *file;
	const inode = file.inode: *inode;
	if (io::isdir(inode.mode)) {
		if (file.diter.inode_ref != null) {
			lwext4::dir_iterator_fini(&file.diter);
		};
	} else {
		if (file.lwfile.mp != null) {
			lwext4::fclose(&file.lwfile);
		};
	};
	free(file);
};
