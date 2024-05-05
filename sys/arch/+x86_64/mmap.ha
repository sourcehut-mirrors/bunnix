use arch::x86_64;
use arch::x86_64::{pml4, pml4e, pdpt, pdpte, pd, pde, pt, pte};
use arch::x86_64::{PADDR_MASK};
use boot;
use types;

// Memory map is defined in hare.sc, including kernel page tables
export def IDENT_PDS: size = 64;
export def IDENT_START: uintptr = 0xFFFFFF8000000000: uintptr;
export def IDENT_SIZE: size = IDENT_PDS * 1024 * 1024 * 1024;
export def IDENT_END: uintptr = IDENT_START + IDENT_SIZE: uintptr;

let kernel_pml4: *pml4 = null: *pml4;
let kernel_pml4_phys: uintptr = 0;
let kernel_pdpt: *pdpt = null: *pdpt;
let kernel_pdpt_phys: uintptr = 0;
let kernel_pt: *pt = null: *pt;

let @symbol("_kernel_start") kernel_start: u8;
let @symbol("_kernel_end") kernel_end: u8;

// Initialize MMU-related data structures.
export fn mmu_init(bootctx: *boot::context) *boot::context = {
	// Fetch kernel page tables from bootloader
	kernel_pml4_phys = x86_64::rdcr3(): uintptr;
	kernel_pml4 = phys_tokernel(kernel_pml4_phys): *pml4;

	// Unmap lower half
	const low = getpml4e(kernel_pml4_phys, 0);
	*low &= ~pml4e::P;

	const pml4e = getpml4e(kernel_pml4_phys, &kernel_start: uintptr);
	kernel_pdpt_phys = *pml4e: uintptr & PADDR_MASK;
	kernel_pdpt = phys_tokernel(kernel_pdpt_phys): *pdpt;

	const pde = getpde(kernel_pml4_phys, &kernel_start: uintptr) as *pde;
	const pt_phys = *pde: uintptr & PADDR_MASK;
	kernel_pt = phys_tokernel(pt_phys): *pt;

	// Move boot context into upper half
	bootctx = phys_tokernel(bootctx: uintptr): *boot::context;
	bootctx.dtb = phys_tokernel(bootctx.dtb: uintptr);

	if (bootctx.fb.fb_base != 0) {
		bootctx.fb.fb_base = phys_tokernel(bootctx.fb.fb_base): uintptr;
	};

	let cmdline = &bootctx.cmdline: *types::string;
	cmdline.data = phys_tokernel(cmdline.data: uintptr): *[*]u8;

	let mmap = &bootctx.mmap: *types::slice;
	mmap.data = phys_tokernel(mmap.data: uintptr);

	let mods = &bootctx.mods: *types::slice;
	mods.data = phys_tokernel(mods.data: uintptr);

	return bootctx;
};

// Maps the kernel in the higher half of the given page table.
export fn map_kernel(pml4: *pml4) void = {
	pml4[511] = kernel_pdpt_phys | pde::P | pde::W;
};

// Maps a physical memory address to the kernel's identity-mapped address space.
export fn phys_tokernel(ptr: uintptr) *opaque = {
	assert(ptr < IDENT_START); // Lower half
	return (ptr | IDENT_START): *opaque;
};

// Maps a kernel address to physical memory.
export fn kernel_tophys(ptr: nullable *opaque) uintptr = {
	if (ptr == null) {
		return 0;
	};
	const ptr = ptr: uintptr;
	if (ptr >= IDENT_START && ptr < IDENT_END) {
		return ptr & ~IDENT_START;
	};

	assert(ptr >= &kernel_start: uintptr && ptr <= &kernel_end: uintptr);
	const pti = ptr >> 12 & 0x1FF;
	const phys = (kernel_pt[pti] & ~(0x7ff | (1 << 63))): uintptr;
	assert(phys != 0);
	return phys;
};

// Gets the PML4 entry associated with a virtual address in this PML4.
export fn getpml4e(
	table: uintptr,
	vaddr: uintptr,
) *pml4e = {
	const pml4i = vaddr >> 39 & 0x1FF;
	let pml4 = phys_tokernel(table): *pml4;
	return &pml4[pml4i];
};

// Gets the PDPT entry associated with a virtual address in this PML4.
export fn getpdpte(
	table: uintptr,
	vaddr: uintptr,
) nullable *pdpte = {
	const pdpti = vaddr >> 30 & 0x1FF;
	let pml4 = getpml4e(table, vaddr);
	if (*pml4 & pml4e::P == 0) {
		return null;
	};
	const pdptphys = (*pml4 & ~0x7FF): uintptr;
	let pdpt = phys_tokernel(pdptphys): *pdpt;
	return &pdpt[pdpti];
};

// Gets the PD entry associated with a virtual address in this PML4.
export fn getpde(
	table: uintptr,
	vaddr: uintptr,
) nullable *pde = {
	const pdi = vaddr >> 21 & 0x1FF;
	let pdpt = match (getpdpte(table, vaddr)) {
	case let pdpt: *pdpte =>
		yield pdpt;
	case null =>
		return null;
	};
	if (*pdpt & pdpte::P == 0) {
		return null;
	};
	const pdphys = (*pdpt & ~0x7FF): uintptr;
	let pd = phys_tokernel(pdphys): *pd;
	return &pd[pdi];
};

// Gets the PT entry associated with a virtual address in this PML4.
export fn getpte(
	table: uintptr,
	vaddr: uintptr,
) nullable *pte = {
	const pti = vaddr >> 12 & 0x1FF;
	let pd = match (getpde(table, vaddr)) {
	case let pd: *pde =>
		yield pd;
	case null =>
		return null;
	};
	if (*pd & pde::P == 0) {
		return null;
	};
	const ptphys = (*pd & ~0x7FF): uintptr;
	let pt = phys_tokernel(ptphys): *pt;
	return &pt[pti];
};
