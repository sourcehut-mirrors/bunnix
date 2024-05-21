use errors::{error, errno};
use fs;
use io;
use sort;
use strings;

// A memfs inode.
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

fn mkinode(
	sb: *superblock,
	ino: uint,
	mode: io::mode,
	parent: nullable *inode,
) *inode = {
	const ino = alloc(inode {
		impl = &inode_dir_impl,
		sb = sb,
		ino = ino,
		mode = mode,
		...
	});

	if (io::isdir(mode)) {
		inode_link(ino, ino, ".")!;
		match (parent) {
		case let p: *inode =>
			inode_link(ino, p, "..")!;
		case null =>
			inode_link(ino, ino, "..")!;
		};
		ino.nlink = 2;
	};

	fs::put_time(&ino.ctime);
	fs::put_time(&ino.mtime);
	fs::put_time(&ino.atime);

	return ino;
};

const inode_dir_impl = io::inode_iface {
	open = &inode_open,
	trunc = &inode_trunc,
	create = &inode_create,
	lookup = &inode_lookup,
	mkdir = &inode_mkdir,
	mknod = &inode_mknod,
	link = &inode_link,
	unlink = &inode_unlink,
	utimens = &inode_utimens,
	...
};

fn inode_open(ino: *io::inode, flag: io::flag) (*io::file | error) = {
	return mkfile(ino: *inode, flag);
};

fn inode_trunc(ino: *io::inode, length: size) (void | error) = {
	const ino = ino: *inode;
	if (!io::isfile(ino.mode)) {
		return;
	};
	if (len(ino.data) == length) {
		return;
	} else if (len(ino.data) > length) {
		delete(ino.data[length..]);
	} else {
		append(ino.data, [0...], length - len(ino.data));
	};
	fs::put_time(&ino.ctime);
	fs::put_time(&ino.mtime);
};

fn inode_mkchild(ino: *io::inode, name: str, mode: io::mode) (*io::inode | error) = {
	const parent = ino: *inode;
	assert(io::isdir(parent.mode));
	if (dir_findchild(parent, name) != null) {
		return errno::EXIST;
	};

	const sb = parent.sb;
	const ino = sb_get_ino(sb);
	const child = mkinode(sb, ino, mode, parent);
	const dent = dirent {
		name = strings::dup(name),
		inode = child,
	};
	const i = sort::lbisect(parent.entries, size(dirent), &dent, &dent_cmp);
	insert(parent.entries[i], dent);
	child.nlink += 1;

	fs::put_time(&parent.ctime);
	fs::put_time(&parent.mtime);

	return child;
};

fn inode_create(
	ino: *io::inode,
	name: str,
	mode: io::mode,
) (*io::inode | error) = {
	return inode_mkchild(ino, name, mode | io::mode::REG);
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

fn inode_mkdir(
	ino: *io::inode,
	name: str,
	mode: io::mode,
) (*io::inode | error) = {
	return inode_mkchild(ino, name, mode | io::mode::DIR);
};

fn inode_mknod(
	ino: *io::inode,
	name: str,
	mode: io::mode,
	rdev: u64,
) (*io::inode | error) = {
	let child = inode_mkchild(ino, name, mode)?;
	child.rdev = rdev;
	return child;
};

fn inode_link(
	parent: *io::inode,
	child: *io::inode,
	name: str,
) (void | error) = {
	let parent = parent: *inode;
	let child = child: *inode;

	if (dir_findchild(parent, name) != null) {
		return errno::EXIST;
	};

	const dent = dirent {
		name = strings::dup(name),
		inode = child,
	};
	const i = sort::lbisect(parent.entries, size(dirent), &dent, &dent_cmp);
	insert(parent.entries[i], dent);

	child.nlink += 1;

	fs::put_time(&parent.ctime);
	fs::put_time(&parent.mtime);
};

fn inode_unlink(
	parent: *io::inode,
	name: str,
) (void | error) = {
	let parent = parent: *inode;
	assert(io::isdir(parent.mode));

	const model = dirent {
		name = name,
		inode = null: *inode,
	};
	match (sort::search(parent.entries, size(dirent), &model, &dent_cmp)) {
	case let i: size =>
		parent.entries[i].inode.nlink -= 1;
		delete(parent.entries[i]);
	case void =>
		return errno::NOENT;
	};

	fs::put_time(&parent.ctime);
	fs::put_time(&parent.mtime);
};

fn inode_utimens(
	ino: *io::inode,
	atime: nullable *io::timespec,
	mtime: nullable *io::timespec,
) (void | error) = {
	const ino = ino: *inode;
	fs::put_time(&ino.atime, atime);
	fs::put_time(&ino.mtime, atime);
	fs::put_time(&ino.ctime);
};
