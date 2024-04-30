use arch;
use arch::x86_64;
use arch::x86_64::{pml4e, pdpte, pde, pte};
use arch::x86_64::{PAGESIZE, UPAGESIZE, PADDR_MASK};
use errors::{error, errno};

// Forks the specified virtual memory manager.
export fn fork(orig: *vmm, new: *vmm) (void | error) = {
	vmm_enum(orig, &fork_iter, new);
};

fn fork_iter(ent: *pte, vaddr: uintptr, user: nullable *opaque) void = {
	// TODO: copy on write
	let new_vmm = user: *vmm;
	const phys = *ent: uintptr & PADDR_MASK;

	let prot = prot::WRITE | prot::EXEC;
	if (*ent & pte::XD != 0) {
		prot &= ~prot::EXEC;
	};

	let flags = flag::USER | flag::ANON;

	mmap(new_vmm, phys, vaddr, PAGESIZE, prot, flags)!;
	const new_phys = mmap_phys(new_vmm, vaddr);

	let src = arch::phys_tokernel(phys): *[PAGESIZE]u8;
	let dst = arch::phys_tokernel(new_phys): *[PAGESIZE]u8;
	dst[..] = src[..];

	if (*ent & pte::W != 0) {
		prot &= ~prot::WRITE;
		mprotect(new_vmm, vaddr, PAGESIZE, prot)!;
	};
};
