use arch::x86_64;

// Architecture-specific context structure.
export type context = x86_64::context;

// Page size.
export def PAGESIZE: size = x86_64::PAGESIZE;

// Page size, as a uintptr.
export def UPAGESIZE: uintptr = x86_64::UPAGESIZE;
