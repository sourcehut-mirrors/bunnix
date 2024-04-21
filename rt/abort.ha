// See harec:include/gen.h
const reasons: [_]str = [
	"slice or array access out of bounds",			// 0
	"type assertion failed",				// 1
	"out of memory",					// 2
	"static insert/append exceeds slice capacity",		// 3
	"execution reached unreachable code (compiler bug)",	// 4
	"slice allocation capacity smaller than initializer",	// 5
	"assertion failed",					// 6
	"error occurred",					// 7
];

export fn abort_fixed(path: *str, line: u64, col: u64, i: u64) void = {
	target_abort(path, line, col, reasons[i]);
};

export @symbol("rt.abort") fn _abort(
	path: *str,
	line: u64,
	col: u64,
	msg: str,
) never = {
	target_abort(path, line, col, msg);
};
