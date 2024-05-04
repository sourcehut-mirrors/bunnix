use fmt;
use os;

export fn main() void = {
	for (let arg .. os::args[1..]) {
		fmt::printf("{} ", arg)!;
	};
	fmt::println()!;
};
