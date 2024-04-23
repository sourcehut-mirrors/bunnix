use arch::main;		// link
use arch_dev = arch::dev;
use boot;
use dev;
use log;
use mman;
use rt;
// XXX TEMP
use dev::block;

const KERN: str = "kern";

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	mman::init(ctx);

	arch_dev::init();
	dev::scan();

	log::println("Nothing to do; idling");
	rt::halt();
};
