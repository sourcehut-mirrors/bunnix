use errors::{error, errno};
use fs;
use io;
use lib::lwext4;
use types::c;

const file_impl_dir = io::vtable {
	readdir = &dir_readdir,
	finish = &file_finish,
	...
};

// Returns true if the dir_iter was initialized by this call.
fn dir_iter_init(fd: *file) (bool | error) = {
	if (fd.diter.inode_ref != null) {
		return false;
	};
	const inode = fd.inode: *inode;
	let r = lwext4::dir_iterator_init(&fd.diter, &inode.ref, 0);
	if (r != errno::NONE) {
		return r;
	};
	return true;
};

fn dir_readdir(fd: *io::file, dent: *io::dirent) (void | io::EOF | error) = {
	const fd = fd: *file;
	const first = dir_iter_init(fd)?;

	if (fd.diter.curr == null) {
		return io::EOF;
	};

	if (!first) {
		let r = lwext4::dir_iterator_next(&fd.diter);
		if (r != errno::NONE) {
			return r;
		};
	};

	const inode = fd.inode: *inode;
	const sb = inode.sb;
	const fs = &sb.mp.fs;
	const cur = match (fd.diter.curr) {
	case null =>
		return io::EOF;
	case let dent: *lwext4::dir_en =>
		yield dent;
	};
	const nameln = lwext4::dir_en_get_name_len(&fs.sb, cur);
	const name = c::tostrn_unsafe(&cur.name[0], nameln);

	const mode = switch (cur.in.inode_type) {
	case lwext4::EXT4_DE_UNKNOWN =>
		yield io::mode::UNKNOWN;
	case lwext4::EXT4_DE_REG_FILE =>
		yield io::mode::REG;
	case lwext4::EXT4_DE_DIR =>
		yield io::mode::DIR;
	case lwext4::EXT4_DE_CHRDEV =>
		yield io::mode::CHR;
	case lwext4::EXT4_DE_BLKDEV =>
		yield io::mode::BLK;
	case lwext4::EXT4_DE_FIFO =>
		yield io::mode::FIFO;
	case lwext4::EXT4_DE_SOCK =>
		yield io::mode::SOCK;
	case lwext4::EXT4_DE_SYMLINK =>
		yield io::mode::LINK;
	case => abort();
	};

	*dent = io::dirent {
		name = name,
		mode = mode,
		ino = cur.inode,
	};
};
