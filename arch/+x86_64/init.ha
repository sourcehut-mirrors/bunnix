// Initializes architecture-specific kernel state.
export fn init() void = {
	pic_init();
	init_idt();
	init_cpu(0);
};
