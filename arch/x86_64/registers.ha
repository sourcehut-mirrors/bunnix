export fn rdcr0() u64;
export fn rdcr2() u64;
export fn rdcr3() u64;
export fn wrcr3(addr: uintptr) void;
export fn rdcr4() u64;
export fn wrcr4(val: u64) u64;

export def CR4_OSFXSR: u64 = 1 << 9;
export def CR4_OSXMMEXCPT: u64 = 1 << 10;
export def CR4_PCIDE: u64 = 1 << 17;
export def CR4_TSD: u64 = 1 << 2;

// Read the specified MSR.
export fn rdmsr(msr: u32) u64;

// Write the specified MSR.
export fn wrmsr(msr: u32, value: u64) void;

// EFER (extended feature) model-specific register number.
export def MSR_EFER: u32 = 0xC0000080;

// GSBASE MSR
export def MSR_IA32_GS_BASE = 0xC0000101;

// Kernel GSBASE MSR
export def MSR_IA32_KERNEL_GS_BASE = 0xC0000102;

// Syscall segments
export def MSR_IA32_STAR = 0xC0000081;

// Syscall entry point
export def MSR_IA32_LSTAR = 0xC0000082;

// Syscall flags mask
export def MSR_IA32_FMASK = 0xC0000084;
