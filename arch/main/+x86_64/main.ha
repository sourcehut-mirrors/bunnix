use arch;
use arch::dev;
use boot;
use cons;
use log;
use rt;

@symbol("main") fn kmain(ctx: *boot::context) never;

export fn main(ctx: *boot::context) never = {
	static let vgacons = dev::vga_console { ... };
	const vgabase = arch::phys_tokernel(dev::VGA_CONSBASE: uintptr);
	dev::vga_init(&vgacons, vgabase: *[dev::VGA_CELLS]u16);

	static let serialcons = dev::serial_console { ... };
	dev::serial_init(&serialcons, dev::SERIAL_PORT_A);

	static let cons = cons::multi_console { ... };
	cons::all(&cons);
	log::setcons(&cons);
	rt::abortcons(&log::write);

	rt::do_init();

	kmain(ctx);
};
