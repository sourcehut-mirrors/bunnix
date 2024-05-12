use bytes;
use dev;
use errors::{error, errno};
use io;

let devnospc_chardev_impl = chardev_iface {
	open = &nospc_open,
};

let devnospc = chardev {
	iface = &devnospc_chardev_impl,
	major = dev::MEM_MAJOR,
	minor = dev::NOSPC_MINOR,
};

@init fn devnospc() void = {
	register(&devnospc);
};

fn nospc_open(cdev: *chardev) (*io::file | error) = {
	return alloc(io::file {
		vtable = &devnospc_file_impl,
		...
	});
};

let devnospc_file_impl = io::vtable {
	read = &nospc_read,
	write = &nospc_write,
	seek = &nospc_seek,
	finish = &nospc_finish,
	...
};

fn nospc_read(file: *io::file, buf: []u8) (size | io::EOF | error) = {
	bytes::zero(buf);
	return len(buf);
};

fn nospc_write(file: *io::file, buf: const []u8) (size | error) = {
	return errno::NOSPC: error;
};

fn nospc_seek(file: *io::file, offs: i64, w: io::whence) (i64 | error) = {
	return 0;
};

fn nospc_finish(file: *io::file) void = {
	free(file);
};
