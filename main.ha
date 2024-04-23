use arch::main;		// link
use arch_dev = arch::dev;
use boot;
use dev;
use log;
use mman;
use rt;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	mman::init(ctx);

	arch_dev::init();
	dev::scan();

	log::println("Nothing to do; idling");
	rt::halt();
};
