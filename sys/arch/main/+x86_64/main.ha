use arch;
use arch::dev;
use boot;
use io;
use log;
use rt;
use sched;

@symbol("main") fn kmain(ctx: *boot::context) never;

export fn main(ctx: *boot::context) never = {
	// Set up a working console as early as possible
	static let vgacons = dev::vga_console {
		vtable = null: *io::vtable,
		...
	};
	const vgabase = arch::phys_tokernel(dev::VGA_CONSBASE: uintptr);
	dev::vga_init(&vgacons, vgabase: *[dev::VGA_CELLS]u16);

	static let serialcons = dev::serial_console {
		vtable = null: *io::vtable,
		...
	};
	dev::serial_init(&serialcons, dev::SERIAL_PORT_A);

	static let cons = io::teefile {
		vtable = null: *io::vtable,
		primary = null: *io::file,
		secondary = null: *io::file,
		...
	};
	cons = io::tee(&vgacons, &serialcons);
	log::setcons(&cons);
	rt::abortcons(&log::write);

	ctx = arch::mmu_init(ctx);

	// Run @init functions
	rt::do_init();

	// x86_64 initialization
	arch::earlyinit();

	arch::install_irq(arch::PIT_IRQ, &pit_irq);
	arch::pit_setphase(100);

	// Kernel proper
	kmain(ctx);
};

fn pit_irq(ctx: *arch::context, irq: u8) void = {
	arch::pic_eoi(arch::PIT_IRQ);
	sched::schedule();
};
