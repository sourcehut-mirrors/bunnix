use errors::{errno, error};
use io;

// File descriptor data structure.
export type filedesc = struct {
	file: nullable *io::file,
	inode: nullable *io::inode,
	oflag: io::flag,
};

// Installs the given [[file]] in the process's file descriptor table, returning
// the assigned file descriptor number.
export fn installfd(
	proc: *proc,
	file: *io::file,
	oflag: io::flag = io::flag::RDWR,
	inode: nullable *io::inode = null,
) int = {
	const fd = filedesc {
		file = file,
		inode = inode,
		oflag = oflag,
	};

	for (let i = 0z; i < len(proc.fds); i += 1) {
		if (proc.fds[i].file == null) {
			proc.fds[i] = fd;
			return i: int;
		};
	};

	append(proc.fds, fd);
	return (len(proc.fds) - 1): int;
};

// Returns a reference to a file descriptor in this process's file table.
export fn getfd(
	proc: *proc,
	fd: int,
	allocate: bool = false,
) (*filedesc | error) = {
	if (allocate && fd: size >= len(proc.fds)) {
		append(proc.fds, [filedesc { ... }...], len(proc.fds) - fd: size);
	};

	if (fd < 0 || fd: size > len(proc.fds)) {
		return errno::BADF;
	};
	if (proc.fds[fd].file == null && !allocate) {
		return errno::BADF;
	};
	return &proc.fds[fd];
};

// Returns a reference to an available file descriptor whose fd number is
// greater than or equal to the min argument.
export fn getavailfd(
	proc: *proc,
	min: *int,
) (*filedesc | error) = {
	for (true) {
		if (*min: size >= len(proc.fds)) {
			append(proc.fds,
				[filedesc { ... }...],
				len(proc.fds) - *min: size);
		};

		if (proc.fds[*min].file != null) {
			return &proc.fds[*min];
		};

		*min += 1;
	};
};

// Closes a file descriptor in this process's file table.
export fn closefd(proc: *proc, fd: int) (void | error) = {
	let fd = getfd(proc, fd)?;
	let file = fd.file: *io::file;
	io::unref(file);
	fd.file = null;
	fd.inode = null;
};
