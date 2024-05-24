#include <assert.h>
#include <string.h>
#include <zlib.h>
#include "bprintf.h"
#include "fs.h"
#include "modules.h"
#include "wstr.h"

#define MAX_MODS 16
#define BUFSIZ 16384

static void *zalloc(void *opaque, unsigned int items, unsigned int size) {
	efi_boot_services *bsvc = opaque;
	void *data;
	int st = bsvc->AllocatePool(EfiLoaderData, items * size, &data);
	if (st != EFI_SUCCESS) {
		bprintfln("Failed to allocate zlib memory");
		return NULL;
	}
	memset(data, 0, items * size);
	return data;
}

static void zfree(void *opaque, void *address) {
	efi_boot_services *bsvc = opaque;
	bsvc->FreePool(address);
}

// Computes the inflated size of a compressed file. Reads the entire file and
// then seeks back to the start.
static size_t inflate_size(efi_boot_services *bsvc, efi_file_protocol *f) {
	static unsigned char in[BUFSIZ];
	static unsigned char out[BUFSIZ];

	z_stream st = {0};
	st.zalloc = &zalloc;
	st.zfree = &zfree;
	st.opaque = bsvc;
	st.avail_in = 0;
	st.next_in = Z_NULL;

	int ret = inflateInit2(&st, 16+MAX_WBITS);
	if (ret != Z_OK) {
		bprintfln("zlib error: %d", ret);
		return 0;
	}

	size_t n = 0;
	do {
		st.avail_in = read(f, in, BUFSIZ);
		if (st.avail_in == 0) {
			break;
		}
		st.next_in = in;

		do {
			st.avail_out = BUFSIZ;
			st.next_out = out;

			ret = inflate(&st, Z_NO_FLUSH);
			assert(ret != Z_STREAM_ERROR);

			switch (ret) {
			case Z_NEED_DICT:
			case Z_DATA_ERROR:
			case Z_MEM_ERROR:
				goto exit;
			}

			n += BUFSIZ - st.avail_out;
		} while (st.avail_out == 0);

	} while (ret != Z_STREAM_END);

exit:
	if (ret != Z_STREAM_END) {
		bprintfln("zlib error: %d", ret);
	}
	inflateEnd(&st);
	seek(f, 0);
	return n;
}

// Decompresses the given file into the memory at the provided location.
static size_t
inflate_load(
	efi_boot_services *bsvc,
	efi_file_protocol *f,
	uint8_t *out) {

	static unsigned char in[BUFSIZ];
	z_stream st = {0};
	st.zalloc = &zalloc;
	st.zfree = &zfree;
	st.opaque = bsvc;
	st.avail_in = 0;
	st.next_in = Z_NULL;

	int ret = inflateInit2(&st, 16+MAX_WBITS);
	if (ret != Z_OK) {
		bprintfln("zlib error: %d", ret);
		return 0;
	}

	size_t n = 0;
	do {
		st.avail_in = read(f, in, BUFSIZ);
		if (st.avail_in == 0) {
			break;
		}
		st.next_in = in;

		do {
			st.avail_out = BUFSIZ;
			st.next_out = &out[n];

			ret = inflate(&st, Z_NO_FLUSH);
			assert(ret != Z_STREAM_ERROR);

			switch (ret) {
			case Z_NEED_DICT:
			case Z_DATA_ERROR:
			case Z_MEM_ERROR:
				goto exit;
			}

			n += BUFSIZ - st.avail_out;
		} while (st.avail_out == 0);

	} while (ret != Z_STREAM_END);

exit:
	if (ret != Z_STREAM_END) {
		bprintfln("zlib error: %d", ret);
	}
	inflateEnd(&st);
	seek(f, 0);
	return n;
}

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

		size_t fullsz = inflate_size(bsvc, file);

		efi_physical_addr *data;
		st = bsvc->AllocatePool(EfiLoaderData, fullsz, (void **)&data);
		if (st != EFI_SUCCESS) {
			bprintfln("Failed to allocate file");
			return st;
		}
		inflate_load(bsvc, file, (uint8_t *)data);
		mod->length = fullsz;
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
