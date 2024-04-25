use errors::{error, errno};
use fs;
use lib::lwext4;
use log;
use types::c;

const file_impl_dir = fs::file_iface {
	readdir = &dir_readdir,
	...
};

fn dir_iter_init(fd: *file) (void | error) = {
	if (fd.diter.inode_ref != null) {
		return;
	};
	const inode = fd.inode: *inode;
	let r = lwext4::dir_iterator_init(&fd.diter, &inode.ref, 0);
	if (r != errno::NONE) {
		return r;
	};
};

fn dir_readdir(fd: *fs::file, dent: *fs::dirent) (void | fs::EOF | error) = {
	const fd = fd: *file;
	dir_iter_init(fd)?;

	if (fd.pos != 0) {
		let r = lwext4::dir_iterator_next(&fd.diter);
		if (r != errno::NONE) {
			return r;
		};
	};
	if (fd.diter.curr == null) {
		lwext4::dir_iterator_fini(&fd.diter);
		return fs::EOF;
	};

	const inode = fd.inode: *inode;
	const sb = inode.sb: *superblock;
	const fs = &sb.mp.fs;
	const cur = match (fd.diter.curr) {
	case null =>
		return fs::EOF;
	case let dent: *lwext4::dir_en =>
		yield dent;
	};
	const nameln = lwext4::dir_en_get_name_len(&fs.sb, cur);
	const name = c::tostrn_unsafe(&cur.name[0], nameln);

	const mode = switch (cur.in.inode_type) {
	case lwext4::EXT4_DE_UNKNOWN =>
		yield fs::mode::UNKNOWN;
	case lwext4::EXT4_DE_REG_FILE =>
		yield fs::mode::REG;
	case lwext4::EXT4_DE_DIR =>
		yield fs::mode::DIR;
	case lwext4::EXT4_DE_CHRDEV =>
		yield fs::mode::CHR;
	case lwext4::EXT4_DE_BLKDEV =>
		yield fs::mode::BLK;
	case lwext4::EXT4_DE_FIFO =>
		yield fs::mode::FIFO;
	case lwext4::EXT4_DE_SOCK =>
		yield fs::mode::SOCK;
	case lwext4::EXT4_DE_SYMLIN =>
		yield fs::mode::LINK;
	case => abort();
	};

	*dent = fs::dirent {
		name = name,
		mode = mode,
		ino = cur.inode,
	};

	fd.pos += 1;
};
