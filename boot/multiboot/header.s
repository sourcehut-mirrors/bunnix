// License: GPL-3.0-only
// License: NCSA
// (c) 2021 K. Lange <klange@toaruos.org>
// (c) 2022 Drew DeVault <sir@cmpwn.com>
.code32
.extern bss_start
.extern _bootloader_start
.extern _bootloader_end

.section .multiboot
.set MB_MAGIC,			0x1BADB002
.set MB_FLAG_PAGE_ALIGN,	1 << 0
.set MB_FLAG_MEMORY_INFO,	1 << 1
.set MB_FLAG_FB,		1 << 2
.set MB_FLAG_ADDR,		1 << 16
.set MB_FLAGS,			MB_FLAG_PAGE_ALIGN | MB_FLAG_MEMORY_INFO | MB_FLAG_ADDR | MB_FLAG_FB
.set MB_CHECKSUM,		-(MB_MAGIC + MB_FLAGS)

.align 4
multiboot_header:
.long MB_MAGIC
.long MB_FLAGS
.long MB_CHECKSUM
.long multiboot_header	/* header_addr */
.long _bootloader_start	/* load_addr */
.long bss_start		/* load_end_addr */
.long _bootloader_end	/* bss_end_addr */
.long _start		/* entry_addr */
.long 0x00000000
.long 1024
.long 768
.long 32

.set MB2_MAGIC,		0xE85250D6
.set MB2_ARCH,		0
.set MB2_LENGTH,	multiboot2_header_end - multiboot2_header
.set MB2_CHECKSUM,	-(MB2_MAGIC + MB2_ARCH + MB2_LENGTH)

.align 8
multiboot2_header:
.long MB2_MAGIC
.long MB2_ARCH
.long MB2_LENGTH
.long MB2_CHECKSUM

.set MB2_ADDR,	2
.set MB2_ENTRY,	3

.align 8
mb2_tag_addr:
.word MB2_ADDR
.word 0
.long 24
.long multiboot2_header
.long _bootloader_start
.long bss_start
.long _bootloader_end

.align 8
mb2_tag_entry:
.word MB2_ENTRY
.word 0
.long 12
.long _start

.align 8
.word 0
.word 0
.long 8
multiboot2_header_end:
