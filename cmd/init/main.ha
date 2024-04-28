use strings;
use rt;

export fn main() void = {
	const data = strings::toutf8("Hello from userspace!\n");
	const vec = rt::vector {
		base = &data[0],
		count = len(data),
	};
	rt::writev(1, vec)!;
};
