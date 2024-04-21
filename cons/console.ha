// Abstract console interface.
export type console = struct {
	write: nullable *fn(cons: *console, buf: []u8) size,
	clear: nullable *fn(cons: *console) void,
};

// Writes data to the console.
export fn write(cons: *console, buf: []u8) size = {
	match (cons.write) {
	case null =>
		return 0;
	case let func: *fn(cons: *console, buf: []u8) size =>
		return func(cons, buf);
	};
};

// Clears the console (if supported, otherwise no-op).
export fn clear(cons: *console) void = {
	match (cons.clear) {
	case null =>
		yield;
	case let func: *fn(cons: *console) void =>
		func(cons);
	};
};
