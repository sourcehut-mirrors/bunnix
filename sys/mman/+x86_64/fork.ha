use arch;
use arch::{phys_tokernel};
use arch::x86_64;
use arch::x86_64::{pml4, pml4e, pdpt, pdpte, pd, pde, pt, pte};
use arch::x86_64::{PAGESIZE, UPAGESIZE, PADDR_MASK};
use errors::{error, errno};

// Forks the specified virtual memory manager.
export fn fork(orig: *vmm, new: *vmm) (void | error) = {
	def PML4_FLAGS: pml4e = pml4e::P | pml4e::U | pml4e::W;
	def PDPT_FLAGS: pdpte = pdpte::P | pdpte::U | pdpte::W;
	def PD_FLAGS: pde = pde::P | pde::U | pde::W;

	// TODO: Handle OOM conditions
	const old_l4 = phys_tokernel(orig.pml4): *pml4;
	const new_l4 = phys_tokernel(new.pml4): *pml4;

	new.brk = orig.brk;

	// Only copies mappings in the lower half (hence len / 2)
	let vaddr = 0: uintptr;
	for (let i = 0z; i < len(old_l4) / 2; i += 1) {
		if (old_l4[i] & pml4e::P == 0) {
			vaddr += 1 << 39;
			continue;
		};

		const old_paddr = old_l4[i]: uintptr & PADDR_MASK;
		const old_pdpt = phys_tokernel(old_paddr): *pdpt;
		let new_paddr = physalloc(size(x86_64::pdpt))!;
		new_l4[i] = new_paddr | PML4_FLAGS;
		let new_pdpt = phys_tokernel(new_paddr): *pd;

		for (let i = 0z; i < len(old_pdpt); i += 1) {
			if (old_pdpt[i] & pdpte::P == 0) {
				vaddr += 1 << 30;
				continue;
			};

			const old_paddr = old_pdpt[i]: uintptr & PADDR_MASK;
			const old_pd = phys_tokernel(old_paddr): *pd;
			let new_paddr = physalloc(size(x86_64::pd))!;
			new_pdpt[i] = new_paddr | PDPT_FLAGS;
			let new_pd = phys_tokernel(new_paddr): *pd;

			for (let i = 0z; i < len(old_pd); i += 1) {
				if (old_pd[i] & pde::P == 0) {
					vaddr += 1 << 21;
					continue;
				};

				const old_paddr = old_pd[i]: uintptr & PADDR_MASK;
				const old_pt = phys_tokernel(old_paddr): *pt;
				let new_paddr = physalloc(size(x86_64::pt))!;
				new_pd[i] = new_paddr | PD_FLAGS;
				let new_pt = phys_tokernel(new_paddr): *pt;

				for (let i = 0z; i < len(old_pt); i += 1) {
					defer vaddr += UPAGESIZE;
					if (old_pt[i] & pte::P == 0) {
						continue;
					};
					fork_page(old_pt, new_pt, i, vaddr)!;
				};
			};
		};
	};
};

fn fork_page(old_pt: *pt, new_pt: *pt, i: size, vaddr: uintptr) (void | error) = {
	let old_pte = old_pt[i];
	let new_pte = &new_pt[i];

	const old_phys = old_pte: uintptr & PADDR_MASK;
	if (old_pte & pte::W == 0) {
		match (ref(old_phys, PAGESIZE)) {
		case void =>
			// Re-use existing mapping if we haven't exceeded the
			// maximum number of refs
			*new_pte = old_pte;
		case error => void;
		};
	};

	// Copy to a new page
	// TODO: Copy on write
	const new_phys = physalloc(PAGESIZE)?;
	const from = phys_tokernel(old_phys): *[PAGESIZE]u8;
	let to = phys_tokernel(new_phys): *[PAGESIZE]u8;
	to[..] = from[..];

	*new_pte = (old_pte & ~PADDR_MASK: pte) | new_phys;
};
