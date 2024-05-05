#ifndef LOAD_H
#define LOAD_H

#include <efi/types.h>
#include <efi/protocol/file.h>

typedef void (__attribute__((sysv_abi)) *kmain_t)(void *ctx);

efi_status kload(efi_boot_services *bsvc, efi_file_protocol *image, kmain_t *entry);

#endif
