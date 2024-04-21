// Boot context data structure
// Only valid with a lower half identity map
export type bootctx = struct {
	// Kernel command line
	cmdline: const str,
	// Memory map
	mmap: []marea,
	// null if no device tree is available
	dtb: nullable *opaque,
	// Boot modules, if provided
	mods: []module,
	// Framebuffer, if available
	fb: nullable *bootfb,
};

// Memory purpose.
export type mtype = enum uint {
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
export type marea = struct {
	// Physical address
	phys: uintptr,
	// Length in pages
	pages: size,
	// Purpose
	mtype: mtype,
};

// Boot module
export type module = struct {
	phys: uintptr,
	length: size,
};

// Framebuffer pixel format.
export type pixel_format = enum uint {
	RGBX8,
	BGRX8,
};

// Framebuffer provided by bootloader. fb_base & fb_size are set to 0 if the
// bootloader did not prepare a framebuffer.
export type bootfb = struct {
	fb_base: uintptr,
	fb_size: size,
	fmt: pixel_format,
	width: u32,
	height: u32,
	stride: u32,
};
