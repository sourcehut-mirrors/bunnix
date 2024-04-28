use errors::{error, errno};
use fs;
use io;
use lib::lwext4;

const file_impl_reg = io::vtable {
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
		fpos = 0,
	};
};

fn file_read(fd: *io::file, buf: []u8) (size | io::EOF | error) = {
	const fd = fd: *file;
	file_init(fd)?;

	let n = 0z;
	let r = lwext4::fread(&fd.lwfile, &buf[0], len(buf), &n);
	if (r != errno::NONE) {
		return r: error;
	};
	if (n == 0) {
		return io::EOF;
	};

	return n;
};

fn file_write(fd: *io::file, buf: const []u8) (size | error) = {
	const fd = fd: *file;
	file_init(fd)?;

	let n = 0z;
	let r = lwext4::fwrite(&fd.lwfile, &buf[0], len(buf), &n);
	if (r != errno::NONE) {
		return r: error;
	};

	return n;
};

fn file_seek(fd: *io::file, offs: i64, w: io::whence) (i64 | error) = {
	static assert(io::whence::SET: u32 == lwext4::SEEK_SET);
	static assert(io::whence::CUR: u32 == lwext4::SEEK_CUR);
	static assert(io::whence::END: u32 == lwext4::SEEK_END);

	const fd = fd: *file;
	file_init(fd)?;

	let r = lwext4::fseek(&fd.lwfile, offs, w: u32);
	if (r != errno::NONE) {
		return r: error;
	};

	return fd.lwfile.fpos: i64;
};
