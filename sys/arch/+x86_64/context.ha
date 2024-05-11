use arch::x86_64;

// Sets the instruction pointer register in a [[context]].
export fn context_set_ip(ctx: *context, ip: uintptr) void = {
	ctx.rip = ip;
};

// Sets the instruction pointer register in a [[context]].
export fn context_get_ip(ctx: *context) uintptr = {
	return ctx.rip: uintptr;
};

// Sets the stack pointer register in a [[context]].
export fn context_set_sp(ctx: *context, sp: uintptr) void = {
	ctx.rsp = sp;
};

// Sets the stack pointer register in a [[context]].
export fn context_get_sp(ctx: *context) uintptr = {
	return ctx.rsp: uintptr;
};

// Sets the ABI registers in a [[context]].
export fn context_set_abi(ctx: *context, regs: u64...) void = {
	let abiregs = [
		&ctx.rdi,
		&ctx.rsi,
		&ctx.rdx,
		&ctx.rcx,
		&ctx.r8,
		&ctx.r9,
	];
	assert(len(regs) <= len(abiregs));
	for (let i = 0z; i < len(regs); i += 1) {
		*abiregs[i] = regs[i];
	};
};

// Sets the ABI return value in a [[context]].
export fn context_set_rval(ctx: *context, r1: u64, r2: u64) void = {
	ctx.rax = r1;
	ctx.rdx = r2;
};
