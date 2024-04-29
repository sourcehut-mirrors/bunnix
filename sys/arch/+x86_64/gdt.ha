use arch::x86_64;
use arch::x86_64::{seg};

export def SEG_KCODE: u16 = 1;
export def SEG_KDATA: u16 = 2;
export def SEG_UDATA: u16 = 3;
export def SEG_UCODE: u16 = 4;
export def SEG_TSS: u16   = 5;

// GDT size in words
def NGDT: uint = 9;

fn init_gdt(cpu: *cpu) void = {
	const code = seg::S | seg::P | seg::X | seg::L;
	const data = seg::S | seg::P | seg::W;
	cpu.gdt[0] = 0;
	cpu.gdt[SEG_KCODE] = code: u64 | 0 << 45;
	cpu.gdt[SEG_KDATA] = data: u64 | 0 << 45;
	cpu.gdt[SEG_UCODE] = code: u64 | 3 << 45; // user mode
	cpu.gdt[SEG_UDATA] = data: u64 | 3 << 45; // user mode

	const addr = &cpu.tss: uintptr: u64;
	const sz = size(x86_64::tss): u64;
	cpu.gdt[SEG_TSS] = (addr & 0x0000000000FFFFFF) << 16
		| (addr & 0x00000000FF000000) << 32
		| (sz - 1 & 0x0FFFF)
		| (sz - 1 & 0xF0000) << 48
		| seg::TSS: u64
		| seg::P: u64;
	cpu.gdt[SEG_TSS + 1] = addr >> 32;
};

fn init_tss(cpu: *cpu) void = {
	cpu.tss = x86_64::tss { ... };
};

fn set_kernel_stack(stack: *opaque) void = {
	getcpu().tss.ist[0] = stack: uintptr;
};
