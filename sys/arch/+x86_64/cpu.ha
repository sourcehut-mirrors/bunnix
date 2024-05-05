use arch::x86_64;

let @symbol("_kernel_stack_top") _kernel_stack_top: [*]u8;

export type cpu = struct {
	// Self reference
	cpu: nullable *cpu,		// 0

	// Current task, kernel virtual address
	task: nullable *context,	// 16

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
	cpus[i].cpu = &cpus[i];

	let cpu = &cpus[len(cpus)-1];
	init_gdt(cpu);
	init_tss(cpu);

	x86_64::lgdt(&cpu.gdt, NGDT);
	x86_64::ltr(SEG_TSS: u16 << 3);

	x86_64::lseg(SEG_KDATA: u16 << 3);
	x86_64::lidt(&idt);

	x86_64::wrmsr(x86_64::MSR_IA32_KERNEL_GS_BASE, cpu: uintptr: u64);
	x86_64::swapgs();

	set_kernel_stack(&_kernel_stack_top);
};

// Return the current CPU.
export fn getcpu() *cpu = {
	return x86_64::rdgs(): uintptr: *cpu;
};
