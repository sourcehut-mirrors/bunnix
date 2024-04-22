use errors::{error, errno};
use fs;

export type inode = struct {
	fs::inode,
	union {
		data: []u8,
		entries: []fs::dirent,
	},
};

fn mkinode(sb: *superblock, ino: uint, mode: fs::mode) inode = {
	return inode {
		impl = &inode_dir_impl,
		sb = sb,
		ino = ino,
		mode = mode,
		...
	};
};

const inode_dir_impl = fs::inode_iface {
	open = &inode_open,
	...
};

fn inode_open(ino: *fs::inode) (*fs::file | error) = {
	return mkfile(ino: *inode);
};
