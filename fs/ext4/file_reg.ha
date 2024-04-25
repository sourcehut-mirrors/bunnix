use errors::{error, errno};
use fs;

const file_impl_reg = fs::file_iface {
	read = &file_read,
	write = &file_write,
	seek = &file_seek,
	...
};

fn init_reg(fd: *fs::file) (void | error) = {
	return;
};

fn file_read(fd: *fs::file, buf: []u8) (size | fs::EOF | error) = {
	abort(); // TODO
};

fn file_write(fd: *fs::file, buf: []u8) (size | error) = {
	abort(); // TODO
};

fn file_seek(fd: *fs::file, offs: i64, w: fs::whence) (size | error) = {
	abort(); // TODO
};
