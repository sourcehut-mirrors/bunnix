use arch;
use arch::x86_64;
use errors::{error, errno};

// Virtual address space object (on x86_64, physical address of a PML4).
export type vspace = uintptr;

// Initializes a new address space, returning [[errno::NOMEM]] if there is not
// sufficient memory.
export fn new_vspace() (vspace | error) = {
	const pml4_phys = physalloc(size(x86_64::pml4))?;
	const pml4 = arch::phys_tokernel(pml4_phys): *x86_64::pml4;
	arch::map_kernel(pml4);
	return pml4_phys;
};

// Activates a virtual address space.
export fn vspace_map(vs: vspace) void = {
	x86_64::wrcr3(vs);
};
