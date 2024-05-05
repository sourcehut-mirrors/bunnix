#include <assert.h>
#include <efi/types.h>
#include <efi/system-table.h>
#include <efi/protocol/loaded-image.h>
#include <efi/protocol/simple-file-system.h>
#include "fs.h"

// Reserve space for file name in wstr
#define EFI_FILE_SIZE sizeof(efi_file_info) + 512

static efi_file_protocol *root = NULL;

efi_status
init_fs(efi_handle image, efi_system_table *systab)
{
	efi_loaded_image_protocol *limage;
	efi_status st = systab->BootServices->HandleProtocol(image,
		&LoadedImageProtocol, (void **)&limage);
	if (st != EFI_SUCCESS) {
		return st;
	}

	efi_simple_file_system_protocol *fs;
	st = systab->BootServices->HandleProtocol(limage->DeviceHandle,
		&SimpleFileSystemProtocol, (void **)&fs);
	return fs->OpenVolume(fs, &root);
}

efi_file_protocol *
open(char16_t *filename, uint64_t mode, uint64_t attrs)
{
	efi_file_protocol *out;
	efi_status st = root->Open(root, &out, filename, mode, attrs);
	if (st != EFI_SUCCESS) {
		return NULL;
	}
	return out;
}

size_t
read(efi_file_protocol *f, void *buf, size_t n)
{
	efi_status st = f->Read(f, &n, buf);
	if (st != EFI_SUCCESS) {
		return 0;
	}
	return n;
}

void
seek(efi_file_protocol *f, uint64_t pos)
{
	efi_status st = f->SetPosition(f, pos);
	assert(st == EFI_SUCCESS);
}

void
close(efi_file_protocol *f)
{
	efi_status st = f->Close(f);
	assert(st == EFI_SUCCESS);
}

const efi_file_info *
readdir(efi_file_protocol *file)
{
	static uint8_t buffer[EFI_FILE_SIZE] = {0};

	size_t n = read(file, buffer, sizeof(buffer));
	if (n == 0) {
		return NULL;
	}

	return (efi_file_info *)buffer;
}
