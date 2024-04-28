use errors::{error, errno};
use io;
use path;

// Flags that apply to a [[walk]] operation.
export type walkflag = enum uint {
	NONE = 0,
	// Terminate walk at the penultimate entry. The final path component can
	// be identified with [[path::nextiter]] on the provided path iterator.
	PARENT = 1 << 0,
};

// Walks a single filesystem (i.e. does not perform a mountpoint lookup) to
// return the indicated inode.
export fn inode_walk(
	root: *inode,
	iter: *path::iterator,
	flag: walkflag = walkflag::NONE,
) (*inode | error) = {
	assert(flag & walkflag::PARENT == 0); // TODO

	let cur = root;
	for (true) {
		const name = match (path::nextiter(iter)) {
		case let n: str =>
			yield n;
		case done =>
			return cur;
		};

		if (io::islink(cur.mode)) {
			return errno::NOTSUP; // TODO
		};
		if (!io::isdir(cur.mode)) {
			return errno::NOENT;
		};

		match (cur.impl.lookup) {
		case let func: *fn_inode_lookup =>
			cur = func(cur, name)?;
		case null =>
			return errno::NOENT;
		};
	};
};

// Walks a VFS from the root to find the node at a given path.
export fn walk(
	root: *vfs,
	path: str,
	flag: walkflag = walkflag::NONE,
) (*inode | error) = {
	const p = path::init(path)!;
	const iter = path::iter(&p);
	const mp = find_mountpoint(root, &iter)?;
	const root = superblock_get_root(mp.sb);
	return inode_walk(root, &iter, flag);
};
