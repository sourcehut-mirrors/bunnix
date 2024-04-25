use errors::{error, errno};
use fs;
use lib::lwext4;
use log;

export type inode = struct {
	fs::inode,
	ref: lwext4::inode_ref,
	inode: *lwext4::inode,
};

fn get_inode(sb: *superblock, ino: u32) (*inode | error) = {
	let ref = lwext4::inode_ref { ... };
	let r = lwext4::fs_get_inode_ref(&sb.lwfs, ino, &ref);
	if (r != errno::NONE) {
		log::println(r: uint);
		return r;
	};

	let lsb = &sb.lwfs.sb;
	let ino = alloc(inode {
		impl = &inode_impl,
		sb = sb,
		ref = ref,
		inode = ref.inode as *lwext4::inode,
		...
	});
	ino.mode = lwext4::inode_get_mode(lsb, ino.inode): fs::mode;
	ino.uid = lwext4::inode_get_uid(ino.inode);
	ino.gid = lwext4::inode_get_gid(ino.inode);
	ino.dev = lwext4::inode_get_dev(ino.inode);
	ino.bytes = lwext4::inode_get_size(lsb, ino.inode);
	ino.blocks = lwext4::inode_get_blocks_count(lsb, ino.inode);
	return ino;
};

const inode_impl = fs::inode_iface {
	open = &ext4_inode_open,
	lookup = &ext4_inode_lookup,
	link = &ext4_inode_link,
	unlink = &ext4_inode_unlink,
	mkdir = &ext4_inode_mkdir,
	rmdir = &ext4_inode_rmdir,
	...
};

fn ext4_inode_open(ino: *fs::inode) (*fs::file | error) = {
	return mkfile(ino: *inode);
};

fn ext4_inode_lookup(ino: *fs::inode, name: str) (*fs::inode | error) = {
	abort(); // TODO
};

fn ext4_inode_link(
	ino: *fs::inode,
	child: *fs::inode,
	name: str,
) (void | error) = {
	abort(); // TODO
};

fn ext4_inode_unlink(ino: *fs::inode, name: str) (void | error) = {
	abort(); // TODO
};

fn ext4_inode_create(
	ino: *fs::inode,
	name: str,
	mode: fs::mode,
) (*fs::inode | error) = {
	abort(); // TODO
};

fn ext4_inode_mkdir(
	ino: *fs::inode,
	name: str,
	mode: fs::mode,
) (*fs::inode | error) = {
	abort(); // TODO
};

fn ext4_inode_rmdir(ino: *fs::inode, name: str) (void | error) = {
	abort(); // TODO
};
