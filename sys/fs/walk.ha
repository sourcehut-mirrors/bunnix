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
	root: *io::inode,
	iter: *path::iterator,
	flag: walkflag = walkflag::NONE,
) ((*io::inode, str) | error) = {
	let cur = root;
	let last_name = "";
	for (true) {
		const name = match (path::nextiter(iter)) {
		case let n: str =>
			yield n;
		case done =>
			return (cur, "");
		};
		defer last_name = name;

		if (io::islink(cur.mode)) {
			io::inode_unref(cur);
			return errno::NOTSUP; // TODO
		};
		if (!io::isdir(cur.mode)) {
			io::inode_unref(cur);
			return errno::NOENT;
		};

		if (cur.mode & io::mode::OTHER_X != 0) {
			void; // ok
		} else if (cur.mode & io::mode::USER_X != 0) {
			void; // TODO
		} else if (cur.mode & io::mode::GROUP_X != 0) {
			void; // TODO
		} else {
			io::inode_unref(cur);
			return errno::ACCES;
		};

		const final = path::peekiter(iter) is void;
		if (final && flag & walkflag::PARENT != 0) {
			return (cur, name);
		};

		const next = io::inode_lookup(cur, name)?;
		io::inode_unref(cur);
		cur = next;
	};
};

// Walks a VFS from the root to find the node at a given path.
export fn walk(
	root: *vfs,
	path: str,
	flag: walkflag = walkflag::NONE,
) ((*io::inode, str) | error) = {
	const p = path::init(path)!;
	const iter = path::iter(&p);
	const mp = find_mountpoint(root, &iter)?;
	const root = superblock_get_root(mp.sb);
	return inode_walk(root, &iter, flag);
};
