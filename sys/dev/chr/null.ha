use dev::{devmajor, devminor_mem};
use errors::{error, errno};
use io;

let devnull_chardev_impl = chardev_iface {
	open = &null_open,
};

let devnull = chardev {
	iface = &devnull_chardev_impl,
	major = devmajor::MEM,
	minor = devminor_mem::NULL,
};

@init fn devnull() void = {
	register(&devnull);
};

fn null_open(cdev: *chardev) (*io::file | error) = {
	return alloc(io::file {
		vtable = &devnull_file_impl,
		...
	});
};

let devnull_file_impl = io::vtable {
	read = &null_read,
	write = &null_write,
	seek = &null_seek,
	finish = &null_finish,
	...
};

fn null_read(file: *io::file, buf: []u8) (size | io::EOF | error) = {
	return io::EOF;
};

fn null_write(file: *io::file, buf: const []u8) (size | error) = {
	return len(buf);
};

fn null_seek(file: *io::file, offs: i64, w: io::whence) (i64 | error) = {
	return 0;
};

fn null_finish(file: *io::file) void = {
	free(file);
};
