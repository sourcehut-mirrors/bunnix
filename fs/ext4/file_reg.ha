use errors::{error, errno};
use fs;

const file_impl_reg = fs::file_iface {
	read = &file_read,
	write = &file_write,
	seek = &file_seek,
	...
};

fn file_init(fd: *file) (void | error) = {
	void; // TODO
};

fn file_read(fd: *fs::file, buf: []u8) (size | fs::EOF | error) = {
	const fd = fd: *file;
	file_init(fd)?;

	abort(); // TODO
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
