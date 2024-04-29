use rt;
use strings;

export fn main() void = {
	const data = strings::toutf8("Hello from userspace!\n");
	rt::write(1, &data[0], len(data))!;
};
