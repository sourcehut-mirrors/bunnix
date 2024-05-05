#ifndef MODULES_H
#define MODULES_H

#include <efi/types.h>
#include <efi/system-table.h>
#include <efi/protocol/file.h>
#include "bootctx.h"

efi_status load_modules (efi_boot_services *bsvc, struct context *ctx,
	efi_file_protocol *modules);

#endif
