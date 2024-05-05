#include <assert.h>
#include <bprintf.h>
#include <efi/boot-services.h>
#include <efi/types.h>
#include <stdint.h>
#include <string.h>
#include "global.h"
#include "bootctx.h"

#define MAX_DESC 512

efi_status
collect_mmap(efi_boot_services *bsvc, struct context *ctx, size_t *map_key)
{
	static uint8_t descriptors[MAX_DESC * sizeof(efi_memory_descriptor)] = {0};

	size_t mmap_size = 0, desc_size = 0;
	uint32_t desc_version = 0;

	efi_status st = bsvc->GetMemoryMap(&mmap_size, NULL, map_key,
		&desc_size, &desc_version);
	assert(st == EFI_BUFFER_TOO_SMALL);
	assert(desc_version == 1);

	/** 
	 * UEFI spec doesn't specify the maximum number of memory descriptors
	 * GetMemoryMap can return.
	 */
	if (mmap_size > sizeof(descriptors)) {
		bprintfln("memory descriptors array too small");
		return EFI_BUFFER_TOO_SMALL;
	}

	st = bsvc->GetMemoryMap(&mmap_size,
		(efi_memory_descriptor *)&descriptors[0],
		map_key, &desc_size, &desc_version);
	if (st != EFI_SUCCESS) {
		bprintfln("BootServices->GetMemoryMap failed");
		return st;
	}

	size_t nmmap = 0;
	static struct marea mareas[MAX_DESC] = {0};
	for (size_t i = 0; i < mmap_size / desc_size; ++i) {
		efi_memory_descriptor *desc =
			(efi_memory_descriptor *)&descriptors[i * desc_size];

		enum mtype mtype;

		// TODO: KERNEL_IMAGE;
		switch (desc->Type) {
		case EfiLoaderCode:
			mtype = LOADER_DATA_RECLAIM;
			break;
		case EfiLoaderData:
			mtype = LOADER_DATA_RUNTIME;
			break;
		case EfiRuntimeServicesCode:
			mtype = EFI_RUNTIME_CODE;
			break;
		case EfiRuntimeServicesData:
			mtype = EFI_RUNTIME_DATA;
			break;
		case EfiConventionalMemory:
			mtype = CONVENTIONAL;
			break;
		case EfiACPIReclaimMemory:
			mtype = ACPI_RECLAIM;
			break;
		case EfiACPIMemoryNVS:
			mtype = ACPI_NVS;
			break;
		default:
			continue;
		}

		mareas[nmmap++] = (struct marea) {
			.phys = desc->PhysicalStart,
			.size = (size_t)desc->NumberOfPages,
			.mtype = mtype,
		};
	}

	size_t slicesz = sizeof(struct marea) * nmmap;
	struct slice *mmap = &ctx->mmap;
	mmap->length = nmmap;
	mmap->capacity = nmmap;
	st = bsvc->AllocatePool(EfiLoaderData, slicesz, (void **)&mmap->data);
	if (st != EFI_SUCCESS) {
		bprintfln("failed to allocate mmap slice");
		return st;
	}

	memcpy(mmap->data, mareas, slicesz);
	return st;
}
