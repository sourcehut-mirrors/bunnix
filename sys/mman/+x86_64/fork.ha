use arch;
use arch::x86_64;
use arch::x86_64::{pml4e, pdpte, pde, pte};
use arch::x86_64::{PAGESIZE, UPAGESIZE, PADDR_MASK};
use errors::{error, errno};
use log;

// Forks the specified virtual memory manager.
export fn fork(orig: *vmm, new: *vmm) (void | error) = {
	vmm_enum(orig, &fork_iter, new);
};

fn fork_iter(pte: *pte, vaddr: uintptr, user: nullable *opaque) void = {
	let new_vmm = user: *vmm;
	log::printfln("fork_iter: {:x} mapped via {:x}",
		vaddr, *pte: uintptr & PADDR_MASK);
};
