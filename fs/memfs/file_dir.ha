use fs;
use errors::{error, errno};

const file_impl_dir = fs::file_iface {
	readdir = &dir_readdir,
	...
};

fn dir_readdir(fd: *fs::file, dent: *fs::dirent) (void | fs::EOF | error) = {
	const fd = fd: *file;
	const inode = fd.inode: *inode;
	if (fd.pos >= len(inode.entries)) {
		return fs::EOF;
	};
	const ent = &inode.entries[fd.pos];
	dent.name = ent.name;
	dent.ino = ent.inode.ino;
	dent.mode = ent.inode.mode;
	fd.pos += 1;
};
