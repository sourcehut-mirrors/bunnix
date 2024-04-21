use arch::main;		// link
use arch;
use arch::x86_64;
use boot;
use log;
use rt;

export fn main(ctx: *boot::context) void = {
	log::println("Bunnix kernel boot");

	log::println("Boot context includes...");
	log::printfln("Kernel command line: {}", ctx.cmdline);
	log::printfln("{} memory areas:", len(ctx.mmap));
	for (let entry .. ctx.mmap) {
		log::printfln("0x{:x} ({} pages): {}",
			entry.phys, entry.pages,
			boot::mtype_str(entry.mtype));
	};
	log::printfln("{} boot module(s)", len(ctx.mods));
	for (let mod .. ctx.mods) {
		log::printfln("0x{:x} ({} bytes)",
			mod.phys, mod.length);
	};

	log::println("Nothing to do now. Spinning forever");

	// XXX TEMP
	arch::pic_unmask(1); // Enable IRQ 1 (keyboard) for testing

	x86_64::sti();
	for (true) void;
};
