// Multiboot magic number
export def MAGIC: u32 = 0x2BADB002;

// Multiboot 2 magic number
export def MAGIC2: u32 = 0x36d76289;

// Multiboot memory type
export type mem_type = enum u32 {
	AVAILABLE = 1,
	RESERVED = 2,
	ACPI_RECLAIMABLE = 3,
	NVS = 4,
	BADRAM = 5,
};

// Multiboot memory map entry
export type mmap_entry = struct @packed {
	sz: u32,
	addr: u64,
	length: u64,
	typ: mem_type,
};

// Multiboot runtime payload
export type multiboot = struct @packed {
	flags: u32,
	mem_lower: u32,
	mem_upper: u32,
	boot_device: u32,
	cmdline: u32,
	mods_count: u32,
	mods_addr: u32,
	syms: union {
		a: struct {
			tabsize: u32,
			strsize: u32,
			addr: u32,
			pad: u32,
		},
		e: struct {
			num: u32,
			sz: u32,
			addr: u32,
			shndx: u32,
		},
	},
	mmap_length: u32,
	mmap_addr: u32,
	drives_length: u32,
	drives_addr: u32,
	config_table: u32,
	boot_loader_name: u32,
	apm_table: u32,
	vbe_control_info: u32,
	vbe_mode_info: u32,
	vbe_mode: u16,
	vbe_interface_seg: u16,
	vbe_interface_off: u16,
	vbe_interface_len: u16,
	framebuffer_addr: u64,
	framebuffer_pitch: u32,
	framebuffer_width: u32,
	framebuffer_height: u32,
	framebuffer_bpp: u8,
	framebuffer_type: u8,
	union {
		struct {
			framebuffer_palette_addr: u32,
			framebuffer_palette_num_colors: u16,
		},
		struct {
			framebuffer_red_field_position: u8,
			framebuffer_red_mask_size: u8,
			framebuffer_green_field_position: u8,
			framebuffer_green_mask_size: u8,
			framebuffer_blue_field_position: u8,
			framebuffer_blue_mask_size: u8,
		},
	},
};

// Multiboot module
export type module = struct {
	start: u32,
	end: u32,
	string: u32,
	reserved: u32,
};

export def INFO_MEMORY: u32 = 1 << 0;
export def INFO_BOOTDEV: u32 = 1 << 1;
export def INFO_CMDLINE: u32 = 1 << 2;
export def INFO_MODS: u32 = 1 << 3;

export def INFO_SYMS: u32 = 1 << 4;
export def INFO_SHDR: u32 = 1 << 5;

export def INFO_MEM_MAP: u32 = 1 << 6;
export def INFO_DRIVE_INFO: u32 = 1 << 7;
export def INFO_CONFIG_TABLE: u32 = 1 << 8;
export def INFO_BOOT_LOADER_NAME: u32 = 1 << 9;
export def INFO_APM_TABLE: u32 = 1 << 10;
export def INFO_VIDEO_INFO: u32 = 1 << 11;

export type vbe_mode_info = struct @packed {
	attributes: u16,
	window_a: u8,
	window_b: u8,
	granularity: u16,
	window_size: u16,
	segment_a: u16,
	segment_b: u16,
	win_func_ptr: u32,
	pitch: u16,
	width: u16,
	height: u16,
	w_char: u8,
	y_char: u8,
	planes: u8,
	bpp: u8,
	banks: u8,
	memory_model: u8,
	bank_size: u8,
	image_pages: u8,
	reserved0: u8,

	red_mask: u8,
	red_position: u8,
	green_mask: u8,
	green_position: u8,
	blue_mask: u8,
	blue_position: u8,
	reserved_mask: u8,
	reserved_position: u8,
	direct_color_attributes: u8,

	framebuffer: u32,
	off_screen_mem_off: u32,
	off_screen_mem_size: u16,
	reserved: [206]u8,
};
