use errors::{error, errno};
use fs;
use io;
use sort;
use strings;

export type inode = struct {
	io::inode,
	sb: *superblock,
	union {
		data: []u8,
		entries: []dirent,
	},
};

export type dirent = struct {
	name: str,
	inode: *inode,
};

fn dent_cmp(a: const *opaque, b: const *opaque) int = {
	const a = a: *dirent;
	const b = b: *dirent;
	return strings::compare(a.name, b.name);
};

// Finds and returns the dirent associated with this name in the given directory
// inode, or returns null if there is no such object.
fn dir_findchild(parent: *inode, name: str) nullable *dirent = {
	assert(io::isdir(parent.mode));
	const model = dirent {
		name = name,
		inode = null: *inode,
	};
	match (sort::search(parent.entries, size(dirent), &model, &dent_cmp)) {
	case let i: size =>
		return &parent.entries[i];
	case void =>
		return null;
	};
};

fn mkinode(sb: *superblock, ino: uint, mode: io::mode) inode = {
	return inode {
		impl = &inode_dir_impl,
		sb = sb,
		ino = ino,
		mode = mode,
		...
	};
};

const inode_dir_impl = io::inode_iface {
	open = &inode_open,
	lookup = &inode_lookup,
	create = &inode_create,
	mkdir = &inode_mkdir,
	...
};

fn inode_open(ino: *io::inode) (*io::file | error) = {
	return mkfile(ino: *inode);
};

fn inode_lookup(ino: *io::inode, name: str) (*io::inode | error) = {
	const ino = ino: *inode;
	match (dir_findchild(ino, name)) {
	case null =>
		return errno::NOENT;
	case let dent: *dirent =>
		return dent.inode;
	};
};

fn inode_mkchild(ino: *io::inode, name: str, mode: io::mode) (*io::inode | error) = {
	const parent = ino: *inode;
	assert(io::isdir(parent.mode));
	if (dir_findchild(parent, name) != null) {
		return errno::EXIST;
	};

	const sb = parent.sb;
	const ino = sb_get_ino(sb);
	const child = alloc(mkinode(sb, ino, mode));
	const dent = dirent {
		name = strings::dup(name),
		inode = child,
	};
	const i = sort::lbisect(parent.entries, size(dirent), &dent, &dent_cmp);
	insert(parent.entries[i], dent);

	return child;
};

fn inode_create(
	ino: *io::inode,
	name: str,
	mode: io::mode,
) (*io::inode | error) = {
	return inode_mkchild(ino, name, mode | io::mode::REG);
};

fn inode_mkdir(
	ino: *io::inode,
	name: str,
	mode: io::mode,
) (*io::inode | error) = {
	return inode_mkchild(ino, name, mode | io::mode::DIR);
};
