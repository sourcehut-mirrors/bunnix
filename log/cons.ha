use io;

let cons: *io::stream = &io::static_empty;

// Sets the kernel console driver.
export fn setcons(to: *io::stream) void = {
	cons = to;
};

// Writes data to the kernel console.
export fn write(buf: []u8) size = {
	return io::write(cons, buf)!;
};
