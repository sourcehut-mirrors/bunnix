use fmt;
use os;

export fn main() void = {
	for (let arg .. os::args) {
		fmt::printf("{} ", arg)!;
	};
	fmt::println()!;
};
