use arch::main;		// link
use arch;
use boot;
use log;
use mman;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	mman::init(ctx);

	log::println("Allocating an address space");
	const vspace = mman::new_vspace()!;
	log::println("And activating it");
	mman::vspace_map(vspace);

	log::println("Nothing else to do...");
	for (true) void;
};
