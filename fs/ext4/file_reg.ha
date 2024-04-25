use errors::{error, errno};
use fs;
use lib::lwext4;
use log;

const file_impl_reg = fs::file_iface {
	read = &file_read,
	write = &file_write,
	seek = &file_seek,
	...
};

fn file_init(file: *file) (void | error) = {
	let inode = file.inode;
	let sb = inode.sb: *superblock;
	let lwfile = &file.lwfile;

	if (lwfile.mp != null) {
		return;
	};

	// Construct a synthetic ext4_file
	*lwfile = lwext4::file {
		mp = &sb.mp,
		inode = inode.ino,
		flags = lwext4::O_RDWR: u32,
		fsize = inode.bytes,
		fpos = file.pos,
	};
};

fn file_read(fd: *fs::file, buf: []u8) (size | fs::EOF | error) = {
	const fd = fd: *file;
	file_init(fd)?;

	let n = 0z;
	let r = lwext4::fread(&fd.lwfile, &buf[0], len(buf), &n);
	if (r != errno::NONE) {
		log::println(r: uint);
		return r: error;
	};

	return n;
};

fn file_write(fd: *fs::file, buf: []u8) (size | error) = {
	const fd = fd: *file;
	file_init(fd)?;

	abort(); // TODO
};

fn file_seek(fd: *fs::file, offs: i64, w: fs::whence) (size | error) = {
	const fd = fd: *file;
	file_init(fd)?;

	abort(); // TODO
};
