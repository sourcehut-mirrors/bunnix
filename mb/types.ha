// Multiboot magic number
export def MB_MAGIC: u32 = 0x2BADB002;

// Multiboot 2 magic number
export def MB2_MAGIC: u32 = 0x36d76289;

// Multiboot info structure
export type multiboot = struct {
	flags: u32,
	mem_lower: u32,
	mem_upper: u32,
	boot_device: u32,
	cmdline: u32,
	mods_count: u32,
	mods_addr: u32,
	// Additional fields omitted
};

// Multiboot module details
export type mb_module = struct {
	start: u32,
	end: u32,
	string: u32,
	reserved: u32,
};

// Multiboot modules flag
def MB_FLAG_MODULES: u32 = 1 << 3;
