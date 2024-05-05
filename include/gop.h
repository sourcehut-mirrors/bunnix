#ifndef GOP_H
#define GOP_H
#include <efi/types.h>
#include "bootctx.h"

efi_status init_gop(efi_boot_services *bsvc, struct context *ctx);

#endif
