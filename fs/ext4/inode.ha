use errors::{error, errno};
use fs;
use lib::lwext4;
use types::c;

export type inode = struct {
	fs::inode,
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
	ino.mode = lwext4::inode_get_mode(&fs.sb, ino.inode): fs::mode;
	ino.uid = lwext4::inode_get_uid(ino.inode);
	ino.gid = lwext4::inode_get_gid(ino.inode);
	ino.dev = lwext4::inode_get_dev(ino.inode);
	ino.bytes = lwext4::inode_get_size(&fs.sb, ino.inode);
	ino.blocks = lwext4::inode_get_blocks_count(&fs.sb, ino.inode);
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
