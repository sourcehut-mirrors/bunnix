use arch;
use arch::{phys_tokernel};
use arch::x86_64;
use arch::x86_64::{pml4, pml4e, pdpt, pdpte, pd, pde, pt, pte};
use arch::x86_64::{PAGESIZE, UPAGESIZE, PADDR_MASK};
use errors::{error, errno};

// Unmaps all memory from this vmm and returns the page tables to the physical
// allocator.
export fn vmm_finish(vmm: *vmm) void = {
	if (x86_64::rdcr3(): uintptr == vmm.pml4) {
		x86_64::wrcr3(kernel.pml4: uintptr);
	};

	let pml4 = arch::phys_tokernel(vmm.pml4): *pml4;
	defer unref(vmm.pml4, PAGESIZE);

	for (let i = 0z; i < len(pml4) / 2; i += 1) {
		if (pml4[i] & pml4e::P == 0) {
			continue;
		};

		const paddr = pml4[i]: uintptr & PADDR_MASK;
		const pdpt = phys_tokernel(paddr): *pdpt;
		defer unref(paddr, PAGESIZE);

		for (let i = 0z; i < len(pdpt); i += 1) {
			if (pdpt[i] & pdpte::P == 0) {
				continue;
			};

			const paddr = pdpt[i]: uintptr & PADDR_MASK;
			const pd = phys_tokernel(paddr): *pd;
			defer unref(paddr, PAGESIZE);

			for (let i = 0z; i < len(pd); i += 1) {
				if (pd[i] & pde::P == 0) {
					continue;
				};

				const paddr = pd[i]: uintptr & PADDR_MASK;
				const pt = phys_tokernel(paddr): *pt;
				defer unref(paddr, PAGESIZE);

				for (let i = 0z; i < len(pt); i += 1) {
					if (pt[i] & pte::P == 0) {
						continue;
					};
					const paddr = pt[i]: uintptr & PADDR_MASK;
					unref(paddr, PAGESIZE);
				};
			};
		};
	};
};
