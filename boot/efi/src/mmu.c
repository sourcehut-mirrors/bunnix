// See helios:rt/hare+x86_64.sc for x86_64 memory map
#include <assert.h>
#include <stddef.h>
#include <string.h>
#include "hboot.h"
#include "mmu.h"

#define IDENT_PDS	64
#define IDENT_START	0xFFFFFF8000000000
#define KERNEL_START	0xFFFFFFFFC0000000
#define IDENT_SIZE	IDENT_PDS * 1024 * 1024 * 1024
#define KERNEL_MAXVIRT	KERNEL_START + 512 * 4096

__attribute__((aligned(4096))) static uintptr_t pml4[512] = {0};
__attribute__((aligned(4096))) static uintptr_t pdpt[512] = {0};

// Identity map
__attribute__((aligned(4096))) static uintptr_t pd_ident[IDENT_PDS][512] = {0};

// Kernel map
__attribute__((aligned(4096))) static uintptr_t pd_kernel[512] = {0};
__attribute__((aligned(4096))) static uintptr_t pt_kernel[512] = {0};

void
init_mmu()
{
	__asm__("cli");

	// Identity map lower half for EFI boot services
	pml4[0] = (uintptr_t)&pdpt | PDE_P | PDE_W;

	// Set up higher half physical identity map at 0xFFFFFF8000000000
	pml4[511] = (uintptr_t)&pdpt | PDE_P | PDE_W;
	for (size_t i = 0; i < IDENT_PDS; i++) {
		pdpt[i] = (uintptr_t)&pd_ident[i] | PDE_P | PDE_W;
	}
	for (size_t i = 0; i < IDENT_PDS; i++)
	for (size_t j = 0; j < 512; j++) {
		uintptr_t phys = (uintptr_t)j * 0x200000 + i * 0x200000 * 512;
		pd_ident[i][j] = phys | PDE_P | PDE_W | PDE_PS | PDE_G;
	}

	// Map kernel at 0xFFFFFFFFC0000000
	pdpt[511] = (uintptr_t)&pd_kernel | PDE_P | PDE_W;
	pd_kernel[0] = (uintptr_t)&pt_kernel | PDE_P | PDE_W;

	__asm__ volatile("movq %0, %%cr3" : : "r"(&pml4) : "memory");
}

void
kmmap(uintptr_t virt, uintptr_t phys, uintptr_t flags)
{
	assert(phys % PAGE_SIZE == 0 && virt % PAGE_SIZE == 0);
	assert(virt >= KERNEL_START && virt < KERNEL_MAXVIRT);
	uintptr_t pti = (virt >> 12) & 0x1FFF;
	pt_kernel[pti] = phys | flags | PT_P | PT_G;
}
