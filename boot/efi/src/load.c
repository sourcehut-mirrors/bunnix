#include <assert.h>
#include <elf.h>
#include <efi/types.h>
#include <efi/protocol/file.h>
#include <string.h>
#include "fs.h"
#include "hboot.h"
#include "load.h"
#include "mmu.h"

efi_status
kload_phdr(efi_boot_services *bsvc, efi_file_protocol *image, Elf64_Phdr *phdr)
{
	efi_status st;
	uint64_t pages = phdr->p_memsz / PAGE_SIZE;
	if (phdr->p_memsz % PAGE_SIZE != 0) ++pages;

	efi_physical_addr phys;
	st = bsvc->AllocatePages(AllocateAnyPages, EfiLoaderData, pages, &phys);
	if (st != EFI_SUCCESS) {
		return st;
	}

	memset((void *)phys, 0, phdr->p_memsz);

	seek(image, phdr->p_offset);
	size_t n = read(image, (void *)phys, phdr->p_filesz);
	assert(n == phdr->p_filesz);

	uintptr_t vaddr = phdr->p_vaddr;
	uintptr_t paddr = (uintptr_t)phys;
	// TODO: Set up PT_XD?
	uintptr_t flags = 0;
	if ((phdr->p_flags & PF_W) != 0) {
		flags |= PT_W;
	}

	for (size_t i = 0; i < pages; i += 1) {
		kmmap(vaddr + i * PAGE_SIZE, paddr + i * PAGE_SIZE, flags);
	}

	return EFI_SUCCESS;
}

efi_status
kload(efi_boot_services *bsvc, efi_file_protocol *image, kmain_t *entry)
{
	Elf64_Ehdr hdr;
	size_t n = read(image, &hdr, sizeof(hdr));
	assert(n == sizeof(hdr));
	if (hdr.e_ident[0] != ELFMAG0) {
		return EFI_LOAD_ERROR;
	}
	if (hdr.e_ident[1] != ELFMAG1) {
		return EFI_LOAD_ERROR;
	}
	if (hdr.e_ident[2] != ELFMAG2) {
		return EFI_LOAD_ERROR;
	}
	if (hdr.e_ident[3] != ELFMAG3) {
		return EFI_LOAD_ERROR;
	}

	*entry = (kmain_t)hdr.e_entry;

	Elf64_Phdr phdr;
	for (size_t i = 0; i < hdr.e_phnum; i++) {
		uint64_t off = hdr.e_phoff + i * hdr.e_phentsize;
		seek(image, off);
		n = read(image, &phdr, sizeof(phdr));
		assert(n == sizeof(phdr));
		kload_phdr(bsvc, image, &phdr);
	}

	return EFI_SUCCESS;
}
