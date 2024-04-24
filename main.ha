use arch::main;		// link
use blibc;		// link
use arch;
use boot;
use dev;
use log;
use mman;
use rt;
// XXX TEMP
use dev::block;
use fs::ext4;

const KERN: str = "kern";

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	// Initialize subsystems
	mman::init(ctx);
	arch::init();

	// Scan for devices
	dev::scan();

	// System startup
	// (TODO)

	const bdev = block::open("sata0b")!;
	const fs = ext4::open(bdev)!;

	log::println("Nothing to do; idling");
	rt::halt();
};
