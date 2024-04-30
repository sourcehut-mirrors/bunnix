// TODO: use iterator design?
use arch;
use arch::x86_64::{pml4, pml4e, pdpt, pdpte, pd, pde, pt, pte};
use arch::x86_64::{PADDR_MASK};

// Callback for [[vmm_enum]].
export type vmm_enum_fn = fn(pte: *pte, vaddr: uintptr, user: nullable *opaque) void;

// Enumerates all mappings in this virtual memory manager.
export fn vmm_enum(
	vmm: *vmm,
	cb: *vmm_enum_fn,
	user: nullable *opaque = null,
) void = {
	const pml4 = arch::phys_tokernel(vmm.pml4): *pml4;
	vmm_enum_pml4(pml4, cb, user);
};

fn vmm_enum_pml4(pml4: *pml4, cb: *vmm_enum_fn, user: nullable *opaque) void = {
	let vaddr = 0: uintptr;
	for (let i = 0z; i < len(pml4); i += 1) {
		if (pml4[i] & pml4e::P != 0) {
			const addr = pml4[i]: uintptr & PADDR_MASK;
			const pdpt = arch::phys_tokernel(addr): *pdpt;
			vmm_enum_pdpt(pdpt, vaddr, cb, user);
		};

		vaddr += 1 << 39;
		if (vaddr & (1 << 47) != 0) {
			break; // Don't enumerate higher-half pages
		};
	};
};

fn vmm_enum_pdpt(
	pdpt: *pdpt,
	vaddr: uintptr,
	cb: *vmm_enum_fn,
	user: nullable *opaque,
) void = {
	for (let i = 0z; i < len(pdpt); i += 1) {
		if (pdpt[i] & pdpte::P != 0) {
			const addr = pdpt[i]: uintptr & PADDR_MASK;
			const pd = arch::phys_tokernel(addr): *pd;
			vmm_enum_pd(pd, vaddr, cb, user);
		};

		vaddr += 1 << 30;
	};
};

fn vmm_enum_pd(
	pd: *pd,
	vaddr: uintptr,
	cb: *vmm_enum_fn,
	user: nullable *opaque,
) void = {
	for (let i = 0z; i < len(pd); i += 1) {
		if (pd[i] & pde::P != 0) {
			const addr = pd[i]: uintptr & PADDR_MASK;
			const pt = arch::phys_tokernel(addr): *pt;
			vmm_enum_pt(pt, vaddr, cb, user);
		};

		vaddr += 1 << 21;
	};
};

fn vmm_enum_pt(
	pt: *pt,
	vaddr: uintptr,
	cb: *vmm_enum_fn,
	user: nullable *opaque,
) void = {
	for (let i = 0z; i < len(pt); i += 1) {
		if (pt[i] & pte::P != 0) {
			cb(&pt[i], vaddr, user);
		};
		vaddr += 4096;
	};
};
