use errors::{error, errno};
use fs;
use io;
use path;
use proc;

// Walks a VFS from a process root to find the node at a given path.
export fn atwalk(
	dirfd: int,
	path: str,
	flag: fs::walkflag = fs::walkflag::NONE,
) ((*io::inode, str) | error) = {
	let start: nullable *io::inode = null;

	const proc = proc::current();
	if (dirfd == AT_FDCWD) {
		if (path::abs(path)) {
			start = proc.root;
		} else {
			start = proc.cwd;
		};
	} else {
		const file = validate_dirfd(dirfd)?;
		start = file.inode as *io::inode;
	};

	const start = start as *io::inode;
	return fs::walk(start, path, flag);
};
