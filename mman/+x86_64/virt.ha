use arch;
use arch::x86_64;
use arch::x86_64::{pml4e, pdpte, pde, pte};
use arch::x86_64::{PAGESIZE, UPAGESIZE, PADDR_MASK};
use errors::{error, errno};
use log;

def BRK_INIT: uintptr = 0x400000000000;

// TODO: Assign ASID to each vspace

// Virtual address space object (on x86_64, physical address of a PML4).
export type vspace = struct {
	// Physical address
	pml4: uintptr,
	// Heap break
	brk: uintptr,
};

// Initializes a new address space, returning [[errno::NOMEM]] if there is not
// sufficient memory.
export fn new_vspace() (*vspace | error) = {
	const pml4_phys = physalloc(size(x86_64::pml4))?;
	const pml4 = arch::phys_tokernel(pml4_phys): *x86_64::pml4;
	arch::map_kernel(pml4);
	return alloc(vspace {
		pml4 = pml4_phys,
		brk = BRK_INIT,
	});
};

// Activates a virtual address space.
export fn vspace_map(vs: *vspace) void = {
	x86_64::wrcr3(vs.pml4);
};

// Maps physical pages into a virtual address space.
export fn mmap(
	vs: *vspace,
	paddr: uintptr,
	vaddr: uintptr,
	length: size,
	prot: prot,
	flags: flag,
) (uintptr | error) = {
	if (vaddr == 0) {
		vaddr = vs.brk;
	};

	let base = vaddr;
	// Sanity test parameters
	if (base % UPAGESIZE != 0) {
		return errno::INVAL;
	};
	if (length == 0) {
		return errno::INVAL;
	};

	const mflag = pte::P | pte::U;
	if (prot & prot::WRITE != 0) {
		mflag |= pte::W;
	};
	// TODO: Enable XD bit
	//if (prot & prot::EXEC == 0) {
	//	mflag |= pte::XD;
	//};

	// TODO: If we fail to allocate memory for the intermediate tables, we
	// should probably free the intermediate tables we allocated for the
	// operation
	for (let i = 0z; i < length; i += PAGESIZE) {
		const phys = paddr + i: uintptr * UPAGESIZE;
		let ent = map_tables(vs, vaddr + i: uintptr * UPAGESIZE)?;
		*ent = phys | mflag;
	};

	return base;
};

fn map_tables(vs: *vspace, vaddr: uintptr) (*pte | error) = {
	const pml4i = vaddr >> 39;
	const pdpti = vaddr >> 30 & 0x1FF;
	const pdi = vaddr >> 21 & 0x1FF;
	const pti = vaddr >> 12 & 0x1FF;

	let pml4 = arch::phys_tokernel(vs.pml4): *x86_64::pml4;
	if (pml4[pml4i] & pml4e::P == 0) {
		const pdpt = physalloc(size(x86_64::pdpt))?;
		pml4[pml4i] = pdpt | pml4e::P | pml4e::U | pml4e::W;
	};

	const pdpt_phys = (pml4[pml4i] & PADDR_MASK): uintptr;
	let pdpt = arch::phys_tokernel(pdpt_phys): *x86_64::pdpt;
	if (pdpt[pdpti] & pdpte::P == 0) {
		const pd = physalloc(size(x86_64::pd))?;
		pdpt[pdpti] = pd | pdpte::P | pdpte::U | pdpte::W;
	};

	const pd_phys = (pdpt[pdpti] & PADDR_MASK): uintptr;
	let pd = arch::phys_tokernel(pd_phys): *x86_64::pd;
	if (pd[pdi] & pde::P == 0) {
		const pt = physalloc(size(x86_64::pt))?;
		pd[pdi] = pt | pde::P | pde::U | pde::W;
	};

	const pt_phys = (pd[pdi] & PADDR_MASK): uintptr;
	let pt = arch::phys_tokernel(pt_phys): *x86_64::pt;
	return &pt[pti];
};
