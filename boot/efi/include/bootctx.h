#ifndef BOOTDATA_H
#define BOOTDATA_H

#include "hare.h"

/**
 * Keep this file in sync with bunnix/sys/boot/proto.ha
 */

// Memory purpose
enum mtype {
	// Conventional memory available for any purpose
	CONVENTIONAL,
	// Reclaimable ACPI memory
	ACPI_RECLAIM,
	// ACPI non-volatile storage
	ACPI_NVS,
	// Loader code
	LOADER_CODE,
	// Reclaimable loader data, including:
	// - bootctx and all associated data structures
	// - boot modules
	LOADER_DATA_RECLAIM,
	// Non-reclaimable loader data, such as page tables
	LOADER_DATA_RUNTIME,
	// EFI runtime services code
	EFI_RUNTIME_CODE,
	// EFI runtime services data
	EFI_RUNTIME_DATA,
	// Loaded kernel image
	KERNEL_IMAGE,
};

// Memory map memory area
struct marea {
	// Physical address
	uintptr_t phys;
	// Length in pages
	size_t size;
	// Purpose
	enum mtype mtype;
};

// Boot module
struct module {
	uintptr_t phys;
	size_t length;
};

// Framebuffer pixel format
enum pixel_format {
	RGBX8,
	BGRX8,
};

// Framebuffer provided by bootloader. fb_base & fb_size are set to 0 if the
// bootloader did not prepare a framebuffer.
struct bootfb {
	uintptr_t fb_base;
	size_t fb_size;
	enum pixel_format fmt;
	uint32_t width, height, stride;
};

/**
 * Keep this file in sync with bunnix/sys/boot/proto.ha
 */

struct bootmemory_region {
	// Physical address of the first byte in the memory region
	uintptr_t phys;
	// Number of 4KiB pages in the memory region
	uint64_t pages;
};

// Boot context data structure
// Only valid with a lower half identity map
struct context {
	// Kernel command line
	struct string cmdline;
	// Memory map
	struct slice mmap; // struct marea
	// NULL if no device tree is available
	uintptr_t dtb;
	// Boot modules, if provided
	struct slice mods; // struct module
	// Framebuffer, if available
	struct bootfb fb; // struct bootfb
};

#endif
