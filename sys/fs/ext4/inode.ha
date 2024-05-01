use errors::{error, errno};
use fs;
use io;
use lib::lwext4;
use types::c;

export type inode = struct {
	io::inode,
	sb: *superblock,
	ref: lwext4::inode_ref,
	inode: *lwext4::inode,
};

fn get_inode(sb: *superblock, ino: u32) (*inode | error) = {
	let ref = lwext4::inode_ref { ... };
	let fs = &sb.mp.fs;
	let r = lwext4::fs_get_inode_ref(fs, ino, &ref);
	if (r != errno::NONE) {
		return r;
	};
	return inode_from_ref(sb, &ref);
};

fn inode_from_ref(sb: *superblock, ref: *lwext4::inode_ref) (*inode | error) = {
	let fs = &sb.mp.fs;
	let ino = alloc(inode {
		impl = &inode_impl,
		sb = sb,
		ref = *ref,
		inode = ref.inode as *lwext4::inode,
		...
	});
	ino.ino = ref.index;
	ino.mode = lwext4::inode_get_mode(&fs.sb, ino.inode): io::mode;
	ino.uid = lwext4::inode_get_uid(ino.inode);
	ino.gid = lwext4::inode_get_gid(ino.inode);
	ino.dev = lwext4::inode_get_dev(ino.inode);
	ino.bytes = lwext4::inode_get_size(&fs.sb, ino.inode);
	ino.blocks = lwext4::inode_get_blocks_count(&fs.sb, ino.inode);
	return ino;
};

const inode_impl = io::inode_iface {
	open = &ext4_inode_open,
	lookup = &ext4_inode_lookup,
	link = &ext4_inode_link,
	unlink = &ext4_inode_unlink,
	mkdir = &ext4_inode_mkdir,
	rmdir = &ext4_inode_rmdir,
	...
};

fn ext4_inode_open(ino: *io::inode) (*io::file | error) = {
	return mkfile(ino: *inode);
};

fn ext4_inode_lookup(ino: *io::inode, name: str) (*io::inode | error) = {
	const ino = ino: *inode;
	const sb = ino.sb: *superblock;
	let result = lwext4::dir_search_result { ... };

	const cname = c::unterminatedstr(name);
	const nameln = len(name): u32;
	let r = lwext4::dir_find_entry(&result, &ino.ref, cname, nameln);
	if (r != errno::NONE) {
		return r;
	};
	const dentry = result.dentry as *lwext4::dir_en;
	return get_inode(sb, dentry.inode)?;
};

fn ext4_inode_link(
	ino: *io::inode,
	child: *io::inode,
	name: str,
) (void | error) = {
	abort(); // TODO
};

fn ext4_inode_unlink(ino: *io::inode, name: str) (void | error) = {
	abort(); // TODO
};

fn ext4_inode_create(
	ino: *io::inode,
	name: str,
	mode: io::mode,
) (*io::inode | error) = {
	abort(); // TODO
};

fn ext4_inode_mkdir(
	ino: *io::inode,
	name: str,
	mode: io::mode,
) (*io::inode | error) = {
	abort(); // TODO
};

fn ext4_inode_rmdir(ino: *io::inode, name: str) (void | error) = {
	abort(); // TODO
};
