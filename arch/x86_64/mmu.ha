// Page size (4096)
export def PAGESIZE: size = 4096;

// [[PAGESIZE]] as a uintptr
export def UPAGESIZE: uintptr = 4096: uintptr;

// Page map level 4 entry, maps up to 256TiB of memory
export type pml4e = pde;

// Page directory pointer table entry, maps up to 1GiB of memory
export type pdpte = pde;

// Page directory entry, maps up to 2MiB of memory
export type pde = enum uintptr {
	P = 1 << 0,
	W = 1 << 1,
	U = 1 << 2,
	PWT = 1 << 3,
	PCD = 1 << 4,
	A = 1 << 5,
	D = 1 << 6,
	PS  = 1 << 7,
	G = 1 << 8,
	PAT = 1 << 12,
	XD = 1 << 63,
};

// Page table entry, maps up to 4KiB of memory
export type pte = enum uintptr {
	P = 1 << 0,
	W = 1 << 1,
	U = 1 << 2,
	PWT = 1 << 3,
	PCD = 1 << 4,
	A = 1 << 5,
	D = 1 << 6,
	PAT  = 1 << 7,
	G = 1 << 8,
	XD = 1 << 63,
};

// Page map level four table.
export type pml4 = [512]pml4e;
// Page directory pointj table.
export type pdpt = [512]pdpte;
// Page directory table.
export type pd = [512]pde;
// Page table.
export type pt = [512]pte;
