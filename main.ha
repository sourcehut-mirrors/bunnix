use arch::main;		// link
use arch_dev = arch::dev;
use boot;
use dev;
use log;
use mman;
use rt;
// XXX TEMP
use dev::block;

const KERN: str = "kern";

export fn main(ctx: *boot::context) void = {
	log::kprintln(KERN, "Bunnix kernel boot");
	log::kprintfln(KERN, "Kernel command line: {}", ctx.cmdline);

	mman::init(ctx);

	arch_dev::init();
	dev::scan();

	const bdevs = block::all();
	if (len(bdevs) >= 1) {
		const block = block::all()[0];
		log::printf("Reading first sector of {}{}... ",
			block::iface_str(block.iface), block.serial);
		let buf: [512]u8 = [0...];
		block::read(block, 0, buf)!;
		log::println("ok");
		log::println("First 128 bytes:");
		log::dump(buf[..128]);
	};

	log::println("Nothing to do; idling");
	rt::halt();
};
