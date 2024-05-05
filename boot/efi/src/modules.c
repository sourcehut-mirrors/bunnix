#include <assert.h>
#include "bprintf.h"
#include "fs.h"
#include "modules.h"
#include "wstr.h"

#define MAX_MODS 16

efi_status load_modules(efi_boot_services *bsvc, struct context *ctx,
		efi_file_protocol *modules)
{
	efi_status st = EFI_SUCCESS;

	struct module mods[MAX_MODS] = {0};

	size_t nmods = 0;
	for (size_t i = 0; i < MAX_MODS; ++i) {
		const efi_file_info *info = readdir(modules);
		if (info == NULL) {
			break;
		}

		if (info->Attribute & EFI_FILE_DIRECTORY ||
				wstrcmp(info->FileName, L".") == 0 ||
				wstrcmp(info->FileName, L"..") == 0) {
			continue;
		}

		char filename[256] = {0};
		conv(info->FileName, filename, sizeof(filename));
		bprintfln("Load boot module /modules/%s", filename);

		struct module *mod = &mods[nmods++];
		mod->length = info->FileSize;
		
		efi_file_protocol *file = NULL;
		modules->Open(modules, &file, info->FileName,
			EFI_FILE_MODE_READ, 0);
		if (file == NULL) {
			bprintfln("Error loading module");
			return EFI_LOAD_ERROR;
		}

		efi_physical_addr *data;
		st = bsvc->AllocatePool(EfiLoaderData, mod->length,
			(void **)&data);
		if (st != EFI_SUCCESS) {
			bprintfln("Failed to allocate file");
			return st;
		}
		size_t n = read(file, data, mod->length);
		assert(n == mod->length);
		mod->phys = (uintptr_t)data;
	}

	size_t slicesz = sizeof(struct module) * nmods;
	struct slice *slice = &ctx->mods;
	slice->length = nmods;
	slice->capacity = nmods;
	st = bsvc->AllocatePool(EfiLoaderData, slicesz, (void **)&slice->data);
	if (st != EFI_SUCCESS) {
		bprintfln("Failed to allocate modules slice");
		return st;
	}

	bsvc->CopyMem(slice->data, mods, slicesz);

	return st;
}
