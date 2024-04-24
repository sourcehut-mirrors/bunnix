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

@symbol("ext4_umount") fn ext4_umount(mount_point: nullable *opaque) int;

const KERN: str = "kern";

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	mman::init(ctx);

	arch::init();

	dev::scan();

	log::println("Nothing to do; idling");
	rt::halt();
};
