use errors::{error, errno};
use fs;
use lib::lwext4;
use log;

export type inode = struct {
	fs::inode,
	lwino: lwext4::inode_ref,
};

fn get_inode(sb: *superblock, ino: u32) (*inode | error) = {
	let ref = lwext4::inode_ref { ... };
	let r = lwext4::fs_get_inode_ref(&sb.lwfs, ino, &ref);
	if (r != errno::NONE) {
		log::println(r: uint);
		return r;
	};

	let ino = alloc(inode {
		impl = &inode_impl,
		sb = sb,
		lwino = ref,
		...
	});

	return ino;
};

const inode_impl = fs::inode_iface {
	...
};
