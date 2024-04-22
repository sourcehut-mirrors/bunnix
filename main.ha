use arch::main;		// link
use boot;
use log;
use mman;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	mman::init(ctx);

	for (true) void;
};
