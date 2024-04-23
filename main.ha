use arch::main;		// link
use arch;
use boot;
use dev;
use log;
use mman;
use rt;

const KERN: str = "kern";

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	mman::init(ctx);

	arch::init();
	dev::scan();

	log::println("Nothing to do; idling");
	rt::halt();
};
