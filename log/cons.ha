use io;

// Global kernel console.
export let cons: *io::file = &io::static_empty;

// Sets the kernel console driver.
export fn setcons(to: *io::file) void = {
	cons = to;
};

// Writes data to the kernel console.
export fn write(buf: []u8) size = {
	return io::write(cons, buf)!;
};
