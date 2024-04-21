use cons;

let cons: *cons::console = &cons::empty;

// Sets the kernel console driver.
export fn setcons(to: *cons::console) void = {
	cons = to;
};

// Writes data to the kernel console.
export fn write(buf: []u8) size = {
	return cons::write(cons, buf);
};
