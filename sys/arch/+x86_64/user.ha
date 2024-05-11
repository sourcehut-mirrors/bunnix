fn isr_return(rsp: uintptr) never;

// Enters userspace via a return from an ISR.
export fn enter_user(ctx: *context) never = {
	let cpu = getcpu();
	cpu.task = ctx;
	set_kernel_stack(&(ctx: *[*]context)[1]);
	isr_return(ctx: uintptr);
};

// Enters userspace via a return from a syscall.
export fn sysret() never;
