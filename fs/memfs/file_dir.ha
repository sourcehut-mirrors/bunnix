use errors::{error, errno};
use fs;
use io;

const file_impl_dir = io::vtable {
	readdir = &dir_readdir,
	...
};

fn dir_readdir(fd: *io::file, dent: *io::dirent) (void | io::EOF | error) = {
	const fd = fd: *file;
	const inode = fd.inode: *inode;
	if (fd.pos >= len(inode.entries)) {
		return io::EOF;
	};
	const ent = &inode.entries[fd.pos];
	dent.name = ent.name;
	dent.ino = ent.inode.ino;
	dent.mode = ent.inode.mode;
	fd.pos += 1;
};
