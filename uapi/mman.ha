use errors::{error, errno};

fn sys_mmap(options: *mmap_options) (u64 | error) = {
	abort(); // TODO
};

fn sys_munmap(addr: *opaque, length: size) (u64 | error) = {
	abort(); // TODO
};

fn sys_mprotect(addr: *opaque, length: size, prot: int) (u64 | error) = {
	abort(); // TODO
};
