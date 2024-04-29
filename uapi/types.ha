export type vector = struct {
	base: *opaque,
	count: size,
};

export type mmap_options = struct {
	addr: *opaque,
	length: size,
	prot: int,
	flags: int,
	fd: int,
	offs: u64,
};
