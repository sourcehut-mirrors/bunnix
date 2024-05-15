let writer: nullable *fn(buf: const []u8) void = null;

// Sets the console for printing abort details.
export fn abortcons(obj: *fn(buf: const []u8) void) void = {
	writer = obj;
};

fn abort_writestr(s: str) void = {
	let buf = *(&s: *[]u8);
	const writer = match (writer) {
	case null =>
		halt();
	case let func: *fn(buf: const []u8) void =>
		yield func;
	};
	return writer(buf);
};

fn target_abort(
	path: *str,
	line: u64,
	col: u64,
	msg: str,
) never = {
	const writer = match (writer) {
	case null => halt();
	case let wr: *fn(buf: const []u8) void =>
		yield wr;
	};

	const prefix = "Kernel Abort: ";
	const sep = ":";
	const sepspace = ": ";
	const linefeed = "\n";

	abort_writestr(prefix);
	abort_writestr(*path);
	abort_writestr(sep);
	writer(u64tos(line));
	abort_writestr(sep);
	writer(u64tos(col));
	abort_writestr(sepspace);
	abort_writestr(msg);
	abort_writestr(linefeed);
	halt();
};
