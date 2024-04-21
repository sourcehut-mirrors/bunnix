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

	log::printfln("TSC measured at {} Hz", arch::tsc_rate);

	log::println("Spinning wheels for 1sec");
	let start = arch::rdtsc();
	let end = start + arch::tsc_rate;
	for (arch::rdtsc() < end) void;
	log::println("Done. Now what?");

	arch::pic_unmask(1); // Enable IRQ 1 (keyboard) for testing

	x86_64::sti();
	for (true) void;
};
