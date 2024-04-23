use arch::x86_64;
use log;

// Forward declaration
fn arch::dev::init() void;

const X86_64: str = "x86_64";

// Flags indicating the availability of machine features
export type machflag = enum u64 {
	NONE	= 0,
	SSE	= 1 << 0,
	PCID	= 1 << 1,
};

// Cache of detected machine features
export let feat = machflag::NONE;

// Initializes architecture-specific kernel state.
export fn init() void = {
	arch::dev::init();
};

// Initializes architecture-specific kernel state, prior to MMU initialization.
export fn earlyinit() void = {
	let cpuid = x86_64::cpuid_out { ... };
	x86_64::cpuid(x86_64::CPUID_FEAT, &cpuid);

	if (cpuid.ecx & x86_64::CPUID_FEAT_ECX_SSE3 != 0) {
		const cr0 = x86_64::rdcr0();
		x86_64::wrcr0((cr0 & ~(1 << 2)) | 1 << 1);
		feat |= machflag::SSE;
	} else {
		log::kprintln(log::WARN, "Warning: SSE is not available");
	};

	let cr4 = x86_64::rdcr4();
	// Enable SSE
	if (feat & machflag::SSE != 0) {
		cr4 |= x86_64::CR4_OSFXSR | x86_64::CR4_OSXMMEXCPT;
	};
	// Enable PCID
	if (cpuid.ecx & x86_64::CPUID_FEAT_ECX_PCID != 0) {
		feat |= machflag::PCID;
		cr4 |= x86_64::CR4_PCIDE;
	} else {
		log::kprintln(log::WARN, "Warning: PCID is not available");
	};
	cr4 &= ~x86_64::CR4_TSD; // Allow rdtsc from userspace
	x86_64::wrcr4(cr4);

	init_tsc();
	log::kprintfln(X86_64, "TSC measured at {} MHz", tsc_rate / 1000000);

	init_pic();
	init_idt();
	init_cpu(0);
};
