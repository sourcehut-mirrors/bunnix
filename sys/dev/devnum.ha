// These are fairly arbitrary. Where equivalents are available from Linux we use
// their device major/minor numbers.

// Device major number assignments.
export type devmajor = enum u32 {
	RESERVED = 0,
	// dev/null, dev/zero, etc
	MEM,
	// dev/console et al
	TTY_ALT,
	// dev/tty*, dev/ttyS*
	TTY,
	// dev/kbd, etc
	INPUT,
	// dev/fb
	FB,
	// dev/sata*
	SATA,
	// dev/atapi*
	ATAPI,
	// dev/nvme*
	NVME,
};

// Device minor number assignments for [[devmajor::MEM]].
export type devminor_mem = enum u32 {
	NULL,		// /dev/null
	ZERO,		// /dev/zero
	NOSPC,		// /dev/nospc
	URANDOM,	// /dev/urandom
};

// Makes a device number from its major and minor components.
export fn mkdev(major: u32, minor: u32) u64 = {
	return major << 32u64 | minor;
};
