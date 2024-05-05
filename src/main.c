#include <assert.h>
#include <efi/system-table.h>
#include <efi/types.h>
#include <stdio.h>
#include "bprintf.h"
#include "bootctx.h"
#include "fs.h"
#include "global.h"
#include "gop.h"
#include "hboot.h"
#include "load.h"
#include "mmap.h"
#include "mmu.h"
#include "modules.h"

efi_system_table *g_systab;
efi_handle *g_image;

efi_status
efi_main(efi_handle image, efi_system_table *systab)
{
	g_systab = systab;
	g_image = image;

	bprintfln("Booting Bunnix x86_64 via EFI from %p", &efi_main);

	efi_status st;
	efi_boot_services *bsvc = systab->BootServices;

	struct context *ctx;
	assert(sizeof(*ctx) <= PAGE_SIZE);
	st = bsvc->AllocatePool(EfiLoaderData, sizeof(*ctx),
		(void **)&ctx);
	bsvc->SetMem(ctx, sizeof(*ctx), 0);

	st = init_fs(image, systab);
	if (st != EFI_SUCCESS) {
		bprintfln("Error initializing EFI filesystem support: %d", st);
		return st;
	}

	efi_file_protocol *kernel = open(L"\\bunnix", EFI_FILE_MODE_READ, 0);
	if (kernel == NULL) {
		bprintfln("Error loading kernel from /bunnix");
		return EFI_LOAD_ERROR;
	}
	bprintfln("Load kernel /bunnix");

	kmain_t entry;
	st = kload(bsvc, kernel, &entry);
	if (st != EFI_SUCCESS) {
		bprintfln("Error loading kernel");
		return st;
	}

	close(kernel);

	efi_file_protocol *modules = open(L"\\modules", EFI_FILE_MODE_READ, 0);
	if (modules == NULL) {
		bprintfln("Error loading boot modules from /modules");
		return EFI_LOAD_ERROR;
	}

	st = load_modules(bsvc, ctx, modules);
	if (st != EFI_SUCCESS) {
		bprintfln("Error loading boot modules");
		return st;
	}
	close(modules);

	// TODO: fetch command line from EFI variables
	ctx->cmdline = (struct string){0};

	size_t map_key;
	st = collect_mmap(bsvc, ctx, &map_key);
	if (st != EFI_SUCCESS) {
		bprintfln("Error collecting EFI memory map: %d", st);
		return st;
	}

	st = init_gop(bsvc, ctx);
	if (st != EFI_SUCCESS) {
		bprintfln("Warning: failed to initialize GOP");
	}
	systab->BootServices->ExitBootServices(image, map_key);

	init_mmu();

	entry(ctx);

	return EFI_LOAD_ERROR; // Unreachable
}
