use errors::{error, errno};
use fs;
use sort;
use strings;

export type inode = struct {
	fs::inode,
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
	assert(fs::isdir(parent.mode));
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
	mkdir = &inode_mkdir,
	...
};

fn inode_open(ino: *fs::inode) (*fs::file | error) = {
	return mkfile(ino: *inode);
};

fn inode_mkchild(ino: *fs::inode, name: str, mode: fs::mode) (*fs::inode | error) = {
	const parent = ino: *inode;
	assert(fs::isdir(parent.mode));
	if (dir_findchild(parent, name) != null) {
		return errno::EXIST;
	};

	const sb = parent.sb: *superblock;
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
	ino: *fs::inode,
	name: str,
	mode: fs::mode,
) (*fs::inode | error) = {
	return inode_mkchild(ino, name, mode | fs::mode::REG);
};

fn inode_mkdir(
	ino: *fs::inode,
	name: str,
	mode: fs::mode,
) (*fs::inode | error) = {
	return inode_mkchild(ino, name, mode | fs::mode::DIR);
};
