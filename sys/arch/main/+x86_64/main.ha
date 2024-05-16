use arch;
use arch::dev;
use boot;
use io;
use log;
use rt;
use sched;
use vt;

@symbol("main") fn kmain(ctx: *boot::context) never;

export fn main(ctx: *boot::context) never = {
	// Initialize the PIC first so that we can install interrupts for early
	// console devices
	arch::init_pic();

	// Set up early console(s)
	dev::earlyinit(ctx);

	ctx = arch::mmu_init(ctx);

	// Run @init functions
	rt::do_init();

	// x86_64 initialization
	arch::earlyinit();

	// TODO: Does this belong in arch::main?
	static let pit_irq = arch::irq_handler { ... };
	arch::install_irq(&pit_irq, arch::PIT_IRQ, &handle_pit_irq);
	arch::pit_setphase(100);

	// Kernel proper
	kmain(ctx);
};

fn handle_pit_irq(irq: u8, user: nullable *opaque) void = {
	arch::irq_ack(irq);

	sched::timer_process();
	sched::schedule();
};
