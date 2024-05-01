use arch::x86_64;
use arch::x86_64::{irq};
use log;

let irq_handlers: [256]nullable *irq_handler = [null...];

// An IRQ handler can be registered with [[install_irq]] to be called upon
// receiving a matching IRQ.
export type irq_handler_func = fn(
	ctx: *context,
	irq: u8,
	user: nullable *opaque,
) void;

export type irq_handler = struct {
	func: nullable *irq_handler_func,
	user: nullable *opaque,
	next: nullable *irq_handler,
};

// Installs an IRQ handler for the given IRQ.
export fn install_irq(
	handler: *irq_handler,
	func: *irq_handler_func,
	irq: u8,
	user: nullable *opaque = null,
) void = {
	pic_unmask(irq);

	handler.next = irq_handlers[irq];
	irq_handlers[irq] = handler;
	handler.func = func;
	handler.user = user;
};

fn irq_handler_dispatch(ctx: *context, irq: u8) void = {
	// TODO: Deal with spurious IRQs
	let cur = irq_handlers[0];
	if (cur == null) {
		log::printfln("unhandled IRQ {}", irq);
		pic_eoi(irq);
		return;
	};

	for (cur != null; cur = (cur: *irq_handler).next) {
		const cur = cur: *irq_handler;
		const func = cur.func as *irq_handler_func;
		func(ctx, irq, cur.user);
	};
};

fn gp_fault(ctx: *context) void = {
	log::printfln("General protection fault @ 0x{:x}:0x{:x}",
		ctx.cs, ctx.rip);
	panic("general protection fault", ctx);
};

fn page_fault(ctx: *context) void = {
	if (ctx.errcode & 1u64 << 2 != 0) {
		log::printf("Page fault at ");
	} else {
		log::printf("Kernel page fault at ");
	};
	if (ctx.errcode & 1u64 << 0 == 0) {
		log::printf("non-present ");
	};
	if (ctx.errcode & 1u64 << 3 != 0) {
		log::printf("reserved ");
	};
	if (ctx.errcode & 1u64 << 4 != 0) {
		log::printf("instruction ");
	};
	log::printfln("address 0x{:x} @ 0x{:x}", x86_64::rdcr2(), ctx.rip);
	panic("page fault", ctx);
};

fn ud(ctx: *context) void = {
	panic("undefined instruction", ctx);
};

fn de(ctx: *context) void = {
	panic("division error", ctx);
};

fn xm(ctx: *context) void = {
	panic("Floating-point exception", ctx);
};

export fn isr_handler(ctx: *context) *context = {
	const intno = ctx.intno: u8;
	switch (intno) {
	case irq::DF =>
		panic("double fault", ctx);
	case irq::GP =>
		gp_fault(ctx);
	case irq::PF =>
		page_fault(ctx);
	case irq::UD =>
		ud(ctx);
	case irq::DE =>
		de(ctx);
	case irq::XM =>
		xm(ctx);
	case =>
		if (ctx.intno >= 32 && ctx.intno < 48) {
			const irq = (ctx.intno - 32): u8;
			irq_handler_dispatch(ctx, irq);
		} else {
			log::printfln("unexpected interrupt {}", ctx.intno);
			panic("unexpected interrupt", ctx);
		};
	};

	return ctx;
};
