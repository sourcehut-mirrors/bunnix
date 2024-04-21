use arch::x86_64;

export type cpu = struct {
	tss: x86_64::tss,
	gdt: [NGDT]u64,
};

// TODO: Make this bigger I guess
export def MAX_CPU: size = 64;

let cpus_static: [MAX_CPU]cpu = [cpu { ... }...];
let cpus: []cpu = [];

@init fn init() void = {
	cpus = cpus_static[..0];
};

// Initialize the Nth CPU (which must be the CPU calling this function)
export fn init_cpu(i: size) void = {
	static append(cpus, cpu { ... });

	let cpu = &cpus[len(cpus)-1];
	init_gdt(cpu);
	init_tss(cpu);

	x86_64::lgdt(&cpu.gdt, NGDT);
	x86_64::ltr(SEG_TSS: u16 << 3);
	x86_64::lidt(&idt);
	x86_64::lseg(SEG_KDATA: u16 << 3);

	// TODO: Set gs/gsbase to the CPU local state
};
