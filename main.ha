use arch::main;		// link
use boot;
use fs;
use fs::memfs;
use log;
use mman;
use rt;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	mman::init(ctx);

	log::println("Initialize memfs as temporary root");
	const memfs = memfs::new();

	log::println("Nothing to do; idling");
	rt::halt();
};
