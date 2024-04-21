// Initializes architecture-specific kernel state.
export fn init() void = {
	init_pic();
	init_tsc();
	init_idt();
	init_cpu(0);
};
