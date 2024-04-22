use arch::main;		// link
use arch;
use boot;
use log;
use mman;
use rt;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	mman::init(ctx);

	log::println("Testing slab allocator");
	let x = alloc(1234);
	log::printfln("Allocated x: {}; *x = {}", x, *x);
	free(x);

	log::println("Slices?");
	let y: []int = [];
	append(y, [1, 2, 3, 4]...);
	assert(len(y) == 4);
	assert(y[0] == 1);
	assert(y[1] == 2);
	assert(y[2] == 3);
	assert(y[3] == 4);
	log::println("works");
	free(y);

	for (true) void;
};
