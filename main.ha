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

	log::println("Mapping pages");
	const phys = mman::physalloc(arch::PAGESIZE)!;
	const vaddr = mman::mmap(vspace, phys, 0, arch::PAGESIZE,
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::NONE)!;
	log::printfln("mapped 0x{:x} to 0x{:x}", phys, vaddr);

	log::println("Activating address space");
	mman::vspace_map(vspace);

	log::printf("Verify 0x{:x} is valid... ", vaddr);
	let test = vaddr: *int;
	*test = 1234;
	assert(*test == 1234);
	log::println("ok");

	log::println("Nothing else to do...");
	for (true) void;
};
