use arch::main;		// link
use blibc;		// link
use arch;
use boot;
use dev;
use dev::block;
use log;
use mman;
use rt;
// For testing:
use lib::lwext4;
use types::c;
use errors::{errno};
use strings;

const KERN: str = "kern";

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	// Initialize subsystems
	mman::init(ctx);
	arch::init();

	// Scan for devices
	dev::scan();

	log::println("Nothing to do; idling");
	rt::halt();
};
