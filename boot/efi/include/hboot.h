#ifndef GLOBAL_H
#define GLOBAL_H
#include <efi/types.h>
#include <efi/system-table.h>

#define PAGE_SIZE 4096

extern efi_system_table *g_systab;

#endif
