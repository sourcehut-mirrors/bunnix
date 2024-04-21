use log;
use rt;

// Logs the contents of a [[context]].
export fn logctx(ctx: *context) void = {
	log::printfln("rax {:x} rcx {:x} rdx {:x} rbx {:x}",
		ctx.rax, ctx.rcx, ctx.rdx, ctx.rbx);
	log::printfln("rbp {:x} rsi {:x} rdi {:x} r8 {:x}",
		ctx.rbp, ctx.rsi, ctx.rdi, ctx.r8);
	log::printfln("r9 {:x} r10 {:x} r11 {:x} r12 {:x}",
		ctx.r9, ctx.r10, ctx.r11, ctx.r12);
	log::printfln("r13 {:x} r14 {:x} r15 {:x} rip {:x}",
		ctx.r13, ctx.r14, ctx.r15, ctx.rip);
	log::printfln("cs {:x} ss {:x} fs {:x}", ctx.cs, ctx.ss, ctx.fs);
	log::printfln("rsp {:x} rflags {:x} intno {:x} err {:x}",
		ctx.rsp, ctx.rflags, ctx.intno, ctx.errcode);
};

// Kernel panic, print panic details to log and halt kernel.
export fn panic(reason: str, ctx: *context) never = {
	log::printfln("!! panic !! {}", reason);
	logctx(ctx);
	log::println("System halted.");
	rt::halt();
};
