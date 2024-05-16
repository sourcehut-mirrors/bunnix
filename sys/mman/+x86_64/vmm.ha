use arch;
use arch::x86_64;
use arch::x86_64::{pml4e, pdpte, pde, pte};
use arch::x86_64::{PAGESIZE, UPAGESIZE, PADDR_MASK};
use bytes;
use errors::{error, errno};

def UBRK_INIT: uintptr = 0x400000000000u64: uintptr;
def GUARD: uintptr = UPAGESIZE * 2;

// TODO: Assign ASID to each vmm

// Virtual address space object (on x86_64, physical address of a PML4).
export type vmm = struct {
	// Physical address
	pml4: uintptr,
	// Heap break
	brk: uintptr,
};

let @symbol("_kernel_brk") kernel_brk: [*]u8;

// Kernel virtual address space.
export let kernel = vmm {
	pml4 = 0,
	brk = 0,
};

@init fn init() void = {
	kernel.pml4 = x86_64::rdcr3(): uintptr;
	kernel.brk = &kernel_brk: uintptr;
};

// Initializes a new address space, returning [[errno::NOMEM]] if there is not
// sufficient memory.
export fn vmm_init(vm: *vmm) (void | error) = {
	const pml4_phys = physalloc(size(x86_64::pml4))?;
	const pml4 = arch::phys_tokernel(pml4_phys): *x86_64::pml4;
	arch::map_kernel(pml4);
	*vm = vmm {
		pml4 = pml4_phys,
		brk = UBRK_INIT,
	};
};

// Activates a virtual address space.
export fn vmm_map(vmm: *vmm) void = {
	x86_64::wrcr3(vmm.pml4);
};

// Returns the physical memory address mapped to this virtual address.
export fn mmap_phys(vmm: *vmm, vaddr: uintptr) uintptr = {
	const pte = arch::getpte(vmm.pml4, vaddr) as *pte;
	return *pte: uintptr & PADDR_MASK;
};

// Change the address of program break.
export fn brk(vmm: *vmm, brk: uintptr) (uintptr | error) = {
	if (brk == 0) {
		return vmm.brk;
	};
	// TODO: Change brk location
	return errno::NOMEM;
};

// Maps physical pages into a virtual address space.
export fn mmap(
	vmm: *vmm,
	paddr: uintptr,
	vaddr: uintptr,
	length: size,
	prot: prot,
	flags: flag,
) (uintptr | error) = {
	let dobrk = vaddr == 0;
	if (vaddr == 0) {
		vaddr = vmm.brk;
	};

	let base = vaddr;
	// Sanity test parameters
	if (base % UPAGESIZE != 0) {
		return errno::INVAL;
	};
	if (length == 0) {
		return errno::INVAL;
	};
	if (length % PAGESIZE != 0) {
		length += PAGESIZE - length % PAGESIZE;
	};

	if (flags & flag::ANON != 0) {
		let aflag = mflag::NONE;
		if (flags & flag::DMA32 != 0) {
			aflag |= mflag::LOWMEM;
		};

		paddr = physalloc(length, aflag)?;
	};

	const mflag = pte::P;
	if (flags & flag::USER != 0) {
		mflag |= pte::U;
	};
	if (flags & flag::CD != 0) {
		mflag |= pte::PCD;
	};
	if (flags & flag::WT != 0) {
		mflag |= pte::PWT;
	};

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
	let i = 0z;
	for (i < length; i += PAGESIZE) {
		const phys = paddr + i;
		const virt = vaddr + i;
		let ent = map_tables(vmm, virt)?;
		assert(*ent & pte::P == 0, "mmap: double map");
		*ent = phys | mflag;
		x86_64::invlpg(virt);
	};

	if (dobrk) {
		vmm.brk += i: uintptr + GUARD;
	};

	return base;
};

// Unmaps pages of memory.
export fn munmap(
	vmm: *vmm,
	addr: uintptr,
	length: size,
) (void | error) = {
	if (addr % UPAGESIZE != 0) {
		return errno::INVAL;
	};
	if (length == 0) {
		return errno::INVAL;
	};
	if (length % PAGESIZE != 0) {
		length += PAGESIZE - length % PAGESIZE;
	};

	for (let i = 0z; i < length; i += PAGESIZE) {
		const virt = addr + i;
		// TODO: Handle null pte here
		let pte = arch::getpte(vmm.pml4, virt) as *pte;
		const phys = *pte & PADDR_MASK;
		unref(phys: uintptr, PAGESIZE);
		*pte &= ~pte::P;
		x86_64::invlpg(virt);
	};
};

// Updates the access protection flags for a range of virtual memory addresses.
export fn mprotect(
	vmm: *vmm,
	addr: uintptr,
	length: size,
	prot: prot,
) (void | error) = {
	if (addr % UPAGESIZE != 0) {
		return errno::INVAL;
	};
	if (length == 0) {
		return errno::INVAL;
	};
	if (length % PAGESIZE != 0) {
		length += PAGESIZE - length % PAGESIZE;
	};

	for (let i = 0z; i < length; i += PAGESIZE) {
		const virt = addr + i: uintptr;
		if (arch::getpte(vmm.pml4, virt) == null) {
			return errno::NOMEM;
		};
	};

	for (let i = 0z; i < length; i += PAGESIZE) {
		const virt = addr + i: uintptr;
		let pte = arch::getpte(vmm.pml4, virt) as *pte;
		let cur = *pte;

		if (prot & prot::WRITE == 0) {
			cur &= ~pte::W;
		} else {
			cur |= pte::W;
		};
		// TODO: Enable/disable XD bit

		*pte = cur;
	};
};

fn map_tables(vmm: *vmm, vaddr: uintptr) (*pte | error) = {
	// Mask out higher half addresses
	def HIGH_MASK: uintptr = ((1 << 48) - 1): uintptr;
	vaddr = vaddr & HIGH_MASK;

	const pml4i = vaddr >> 39;
	const pdpti = vaddr >> 30 & 0x1FF;
	const pdi = vaddr >> 21 & 0x1FF;
	const pti = vaddr >> 12 & 0x1FF;

	let pml4 = arch::phys_tokernel(vmm.pml4): *x86_64::pml4;
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

// Returns true if there is a valid mapping for this address.
export fn isvalid(
	addr: nullable *opaque,
	length: size,
	write: bool = false,
	vm: nullable *vmm = null,
) bool = {
	const addr = addr: uintptr;
	const aligned = addr & ~(UPAGESIZE - 1);
	length += (addr - aligned): size;
	addr = aligned;

	let pml4: uintptr = 0;
	match (vm) {
	case let vm: *vmm =>
		pml4 = vm.pml4;
	case null =>
		pml4 = x86_64::rdcr3(): uintptr;
	};

	for (let i = 0z; i < length; i += PAGESIZE) {
		const virt = addr + i: uintptr;
		match (arch::getpte(pml4, virt)) {
		case let p: *pte =>
			if (*p & pte::P == 0 || *p & pte::U == 0) {
				return false;
			};
			if (write && *p & pte::W == 0) {
				return false;
			};
		case null =>
			return false;
		};
	};

	return true;
};

// Returns true if there is a valid mapping for this address which is readable
// by the kernel.
export fn kisreadable(
	addr: *opaque,
	length: size,
) bool = {
	const addr = addr: uintptr;
	const aligned = addr & ~(UPAGESIZE - 1);
	length += (addr - aligned): size;
	addr = aligned;

	const pml4 = x86_64::rdcr3(): uintptr;
	for (let i = 0z; i < length; i += PAGESIZE) {
		const virt = addr + i: uintptr;
		match (arch::getpte(pml4, virt)) {
		case let p: *pte =>
			if (*p & pte::P == 0) {
				return false;
			};
		case null =>
			return false;
		};
	};

	return true;
};
