// Data returned from CPUID.
export type cpuid_out = struct {
	edx: u32,
	ecx: u32,
	ebx: u32,
	eax: u32,
};

fn do_cpuid(eax: u32, flags: *cpuid_out) void;

// Reads information from CPUID.
export fn cpuid(eax: u32, out: *cpuid_out) void = {
	do_cpuid(eax, out);
};

// CPUID FEAT leaf index
export def CPUID_FEAT: u32 = 1;

// SSE3 bit of ECX for the [[CPUID_FEAT]] leaf.
export def CPUID_FEAT_ECX_SSE3: u32 = 1 << 0;

// PCID bit of ECX for the [[CPUID_FEAT]] leaf.
export def CPUID_FEAT_ECX_PCID: u32 = 1 << 17;

// CPUID MISC_FEAT leaf index
export def CPUID_MISC_FEAT: u32 = 0x80000001;
