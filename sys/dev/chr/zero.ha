use bytes;
use dev;
use errors::{error, errno};
use io;

let devzero_chardev_impl = chardev_iface {
	open = &zero_open,
};

let devzero = chardev {
	iface = &devzero_chardev_impl,
	major = dev::MEM_MAJOR,
	minor = dev::ZERO_MINOR,
};

@init fn devzero() void = {
	register(&devzero);
};

fn zero_open(cdev: *chardev) (*io::file | error) = {
	return alloc(io::file {
		vtable = &devzero_file_impl,
		...
	})!;
};

let devzero_file_impl = io::vtable {
	read = &zero_read,
	write = &zero_write,
	seek = &zero_seek,
	finish = &zero_finish,
	...
};

fn zero_read(file: *io::file, buf: []u8) (size | io::EOF | error) = {
	bytes::zero(buf);
	return len(buf);
};

fn zero_write(file: *io::file, buf: const []u8) (size | error) = {
	return len(buf);
};

fn zero_seek(file: *io::file, offs: i64, w: io::whence) (i64 | error) = {
	return 0;
};

fn zero_finish(file: *io::file) void = {
	free(file);
};
