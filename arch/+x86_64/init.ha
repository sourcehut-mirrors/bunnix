use log;

// Initializes architecture-specific kernel state.
export fn init() void = {
	init_tsc();
	log::printfln("TSC measured at {} MHz", tsc_rate / 1000000);

	init_pic();
	init_idt();
	init_cpu(0);
};
