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
	const alloc1 = mman::physalloc(10 * arch::PAGESIZE)!;
	log::printfln("Allocation of ten pages: 0x{:x}", alloc1);
	const alloc2 = mman::physalloc(20 * arch::PAGESIZE)!;
	log::printfln("Allocation of another twenty pages: 0x{:x}", alloc2);

	log::printfln("Increase refcount at 0x{:x}", alloc1);
	mman::ref(alloc1, 10 * arch::PAGESIZE)!;
	log::printfln("Decrease refcount at 0x{:x}", alloc1);
	mman::unref(alloc1, 10 * arch::PAGESIZE);
	mman::unref(alloc1, 10 * arch::PAGESIZE);

	log::print("Reclaim that allocation: ");
	const alloc3 = mman::physalloc(10 * arch::PAGESIZE)!;
	log::printfln("got 0x{:x}", alloc3);
	assert(alloc1 == alloc3);

	log::println("Testing the slab allocator");
	const ptr = mman::slaballoc(32): *int;
	log::printfln("Got 0x{:x} for alloc of 32 bytes", ptr);
	*ptr = 42;
	log::println("Freeing it");
	mman::slabfree(ptr);

	log::println("Try a double free?");
	mman::slabfree(ptr);

	for (true) void;
};
