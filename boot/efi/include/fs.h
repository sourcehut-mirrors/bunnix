#ifndef FS_H
#define FS_H
#include <efi/types.h>
#include <efi/system-table.h>
#include <efi/protocol/file.h>

efi_status init_fs(efi_handle image, efi_system_table *systab);

efi_file_protocol *open(char16_t *filename, uint64_t mode, uint64_t attrs);
size_t read(efi_file_protocol *f, void *buf, size_t n);
void seek(efi_file_protocol *f, uint64_t pos);
void close(efi_file_protocol *f);
const efi_file_info *readdir(efi_file_protocol *file);

#endif
