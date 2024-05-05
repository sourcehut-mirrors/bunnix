#ifndef MMAP_H
#define MMAP_H

#include <efi/types.h>

efi_status collect_mmap(efi_boot_services *bsvc, struct context *ctx,
	size_t *map_key);

#endif
