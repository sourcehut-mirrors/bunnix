use arch;

def STACK_TOP: uintptr = 0x7fff80000000;

fn arch_init(ctx: *arch::context) void = {
	ctx.cs = 0x23;
	ctx.ss = 0x1b;
	ctx.rflags = (1 << 21) | (1 << 9);
};
