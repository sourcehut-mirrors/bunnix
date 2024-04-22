use arch::main;		// link
use arch;
use boot;
use log;
use mman;
use rt;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");
	log::printfln("command line: {}", ctx.cmdline);

	log::printfln("{} memory areas:", len(ctx.mmap));
	for (let entry .. ctx.mmap) {
		log::printfln("0x{:x} ({} pages): {}",
			entry.phys, entry.pages,
			boot::mtype_str(entry.mtype));
	};

	mman::init(ctx);

	log::println("Exercising the page allocator a bit");
	const base = mman::physalloc(10 * arch::PAGESIZE)!;
	log::printfln("Allocation of ten pages: 0x{:x}", base);
	const base = mman::physalloc(20 * arch::PAGESIZE)!;
	log::printfln("Allocation of another twenty pages: 0x{:x}", base);

	for (true) void;
};
