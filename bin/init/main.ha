use rt;
use strings;

export fn main() void = {
	const data = strings::toutf8("Hello world!\n")!;
	rt::write(1, data)!;
};
