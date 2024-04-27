fn isr_return(rsp: uintptr) never;

export fn enter_user(ctx: *context) never = {
	let cpu = getcpu();
	cpu.task = ctx;
	isr_return(ctx: uintptr);
};
