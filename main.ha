use arch::main;		// link
use boot;
use mman;
use log;
use rt;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	mman::init(ctx);

	log::println("Nothing to do; idling");
	rt::halt();
};
