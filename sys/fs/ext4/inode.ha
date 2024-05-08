use errors::{error, errno, strerror};
use fs;
use io;
use lib::lwext4;
use log;
use types::c;

export type inode = struct {
	io::inode,
	sb: *superblock,
	ref: lwext4::inode_ref,
	inode: *lwext4::inode,
};

fn get_inode(sb: *superblock, ino: u32) (*inode | error) = {
	match (fs::icache_get(&sb.ic, ino)) {
	case let ino: *io::inode =>
		return ino: *inode;
	case error => void;
	};

	let ref = lwext4::inode_ref { ... };
	let fs = &sb.mp.fs;
	let r = lwext4::fs_get_inode_ref(fs, ino, &ref);
	if (r != errno::NONE) {
		return r;
	};

	const ino = inode_from_ref(sb, &ref);
	fs::icache_put(&sb.ic, ino);
	return ino;
};

fn inode_from_ref(sb: *superblock, ref: *lwext4::inode_ref) *inode = {
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
	ino.nlink = lwext4::inode_get_links_cnt(ino.inode);
	return ino;
};

const inode_impl = io::inode_iface {
	open = &ext4_inode_open,
	create = &ext4_inode_create,
	trunc = &ext4_inode_trunc,
	link = &ext4_inode_link,
	unlink = &ext4_inode_unlink,
	lookup = &ext4_inode_lookup,
	mkdir = &ext4_inode_mkdir,
	rmdir = &ext4_inode_rmdir,
	finish = &ext4_inode_finish,
	...
};

fn ext4_inode_open(ino: *io::inode) (*io::file | error) = {
	return mkfile(ino: *inode);
};

fn ext4_inode_create(
	parent: *io::inode,
	name: str,
	mode: io::mode,
) (*io::inode | error) = {
	const parent = parent: *inode;
	const fs = &parent.sb.mp.fs;
	if (fs.read_only) {
		return errno::ROFS;
	};

	let child_ref = lwext4::inode_ref { ... };
	let r = lwext4::fs_alloc_inode(fs, &child_ref, lwext4::EXT4_DE_REG_FILE);
	if (r != errno::NONE) {
		return r;
	};

	lwext4::fs_inode_blocks_init(fs, &child_ref);
	lwext4::inode_set_mode(&fs.sb, child_ref.inode,
		(io::mode_perm(mode) | io::mode::REG): u32);

	const child = inode_from_ref(parent.sb, &child_ref);
	match (ext4_inode_link(parent, child, name)) {
	case void =>
		return child;
	case let err: error =>
		lwext4::fs_free_inode(&child_ref);

		// Release the inode's block reference
		child_ref.dirty = false;
		lwext4::fs_put_inode_ref(&child_ref);

		return err;
	};
};

fn ext4_inode_trunc(ino: *io::inode, length: size) (void | error) = {
	const ino = ino: *inode;
	if (length > ino.bytes) {
		abort(); // TODO: shim this, lwext4 does not support it
	};

	let r = lwext4::fs_truncate_inode(&ino.ref, length);
	if (r != errno::NONE) {
		return r;
	};
};

fn ext4_inode_link(
	parent: *io::inode,
	child: *io::inode,
	name: str,
) (void | error) = {
	const parent = parent: *inode;
	const child = child: *inode;

	match (ext4_inode_lookup(parent, name)) {
	case *io::inode =>
		return errno::EXIST;
	case error => void;
	};

	_ext4_inode_link(parent, child, name)?;

	let r = lwext4::fs_put_inode_ref(&parent.ref);
	if (r != errno::NONE) {
		return r;
	};

	lwext4::fs_inode_links_count_inc(&child.ref);
	child.nlink += 1;

	r = lwext4::fs_put_inode_ref(&child.ref);
	if (r != errno::NONE) {
		return r;
	};
};

fn _ext4_inode_link(
	parent: *io::inode,
	child: *io::inode,
	name: str,
) (void | error) = {
	const parent = parent: *inode;
	const child = child: *inode;
	let r = lwext4::dir_add_entry(&parent.ref,
		c::unterminatedstr(name),
		len(name): u32,
		&child.ref);
	if (r != errno::NONE) {
		return r;
	};
};

fn ext4_inode_unlink(parent: *io::inode, name: str) (void | error) = {
	const parent = parent: *inode;
	const child = ext4_inode_lookup(parent, name)?: *inode;

	if (io::isdir(child.mode)) {
		// unlink(2) cannot remove directories per POSIX
		return errno::PERM;
	};

	_ext4_inode_unlink(parent, child, name)?;

	let r = lwext4::fs_put_inode_ref(&parent.ref);
	if (r != errno::NONE) {
		return r;
	};

	r = lwext4::fs_put_inode_ref(&child.ref);
	if (r != errno::NONE) {
		return r;
	};
};

fn _ext4_inode_unlink(
	parent: *io::inode,
	child: *io::inode,
	name: str,
) (void | error) = {
	const parent = parent: *inode;
	const child = child: *inode;

	let r = lwext4::dir_remove_entry(&parent.ref,
		c::unterminatedstr(name),
		len(name): u32);
	if (r != errno::NONE) {
		return r;
	};

	// Decrement link count of parent when removing ..
	// Note that the actual removal of .. is handled by rmdir
	if (io::isdir(child.mode)) {
		lwext4::fs_inode_links_count_dec(&parent.ref);
		parent.ref.dirty = true;
	};

	lwext4::fs_inode_links_count_dec(&child.ref);
	child.ref.dirty = true;
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
	const targ = get_inode(sb, dentry.inode)?;

	r = lwext4::dir_destroy_result(&ino.ref, &result);
	if (r != errno::NONE) {
		return r;
	};

	return targ;
};

fn ext4_inode_mkdir(
	parent: *io::inode,
	name: str,
	mode: io::mode,
) (*io::inode | error) = {
	const parent = parent: *inode;
	const fs = &parent.sb.mp.fs;
	if (fs.read_only) {
		return errno::ROFS;
	};

	let child_ref = lwext4::inode_ref { ... };
	let r = lwext4::fs_alloc_inode(fs, &child_ref, lwext4::EXT4_DE_DIR);
	if (r != errno::NONE) {
		return r;
	};

	lwext4::fs_inode_blocks_init(fs, &child_ref);
	lwext4::inode_set_mode(&fs.sb, child_ref.inode,
		(io::mode_perm(mode) | io::mode::DIR): u32);

	const child = inode_from_ref(parent.sb, &child_ref);
	const hardlinks = [
		(".", child),
		("..", parent),
	];
	for (const (name, ino) .. hardlinks) {
		_ext4_inode_link(child, ino, name)?;
	};

	ext4_inode_link(parent, child, name)?;

	return child;
};

fn ext4_inode_rmdir(ino: *io::inode, name: str) (void | error) = {
	abort(); // TODO
};

fn ext4_inode_finish(ino: *io::inode) void = {
	const ino = ino: *inode;
	// TODO: should we put the lwext4 ref here?
	fs::icache_remove(&ino.sb.ic, ino.ino);
	free(ino);
};
