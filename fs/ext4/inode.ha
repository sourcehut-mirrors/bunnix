use fs;
use lib::lwext4;

export type inode = struct {
	fs::inode,
	lwino: lwext4::inode,
};
