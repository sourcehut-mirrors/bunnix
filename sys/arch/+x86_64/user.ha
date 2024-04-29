fn isr_return(rsp: uintptr) never;

export fn enter_user(ctx: *context) never = {
	let cpu = getcpu();
	cpu.task = ctx;
	set_kernel_stack(&(&ctx: *[*]context)[1]);
	isr_return(ctx: uintptr);
};
