use arch::x86_64;
use arch::x86_64::{pml4e, pdpte, pde, pte};

def KERNEL_START: uintptr = 0xFFFFFFFFC0000000: uintptr;
def KERNEL_MAXVIRT: uintptr = KERNEL_START + 512 * 4096;

def IDENT_PDS: size = 64;
def IDENT_SIZE: size = IDENT_PDS * 1024 * 1024 * 1024;
def IDENT_START: uintptr = 0xFFFFFF8000000000: uintptr;
def IDENT_END: uintptr = IDENT_START + IDENT_SIZE: uintptr;

let @symbol("pml4") pml4: x86_64::pml4;
let @symbol("pdpt") pdpt: x86_64::pdpt;
let @symbol("ident_pd") ident_pd: [IDENT_PDS]x86_64::pd;
let @symbol("kernel_pd") kernel_pd: x86_64::pd;
let @symbol("kernel_pt") kernel_pt: x86_64::pt;

fn mmu_init() void = {
	// Identity map lower half for boot setup
	pml4[0] = &pdpt: uintptr: pml4e | pml4e::P | pml4e::W;

	// Higher half identity map at 0xFFFFFF8000000000
	pml4[511] = &pdpt: uintptr: pml4e | pml4e::P | pml4e::W;
	for (let i = 0z; i < IDENT_PDS; i += 1) {
		pdpt[i] = &ident_pd[i]: uintptr: pdpte | pdpte::P | pdpte::W;

	};
	for (let i = 0z; i < IDENT_PDS; i += 1)
	for (let j = 0z; j < 512; j += 1) {
		const phys = j: uintptr * 0x200000 + i * 0x200000 * 512;
		ident_pd[i][j] = phys: pde | pde::P | pde::W | pde::PS | pde::G;
	};

	// Map kernel at 0xFFFFFFFFC0000000
	pdpt[511] = &kernel_pd: uintptr: pdpte | pdpte::P | pdpte::W;
	kernel_pd[0] = &kernel_pt: uintptr: pde | pde::P | pde::W | pde::G;

	x86_64::wrcr3(&pml4: uintptr);
};
