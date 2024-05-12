// These are fairly arbitrary. Where equivalents are available from Linux we use
// their device major/minor numbers.

export def MEM_MAJOR: u32 = 0;
export def TTY_ALT_MAJOR: u32 = 1;
export def TTY_MAJOR: u32 = 2;
export def INPUT_MAJOR: u32 = 3;
export def FB_MAJOR: u32 = 4;
export def SATA_MAJOR: u32 = 5;
export def ATAPI_MAJOR: u32 = 6;
export def NVME_MAJOR: u32 = 7;

// MEM_MAJOR

export def NULL_MINOR: u32 = 0;
export def ZERO_MINOR: u32 = 1;
export def NOSPC_MINOR: u32 = 2;
export def URANDOM_MINOR: u32 = 3;

// TTY_ALT_MAJOR

export def CONS_MINOR: u32 = 0;

// Makes a device number from its major and minor components.
export fn mkdev(major: u32, minor: u32) u64 = {
	return major << 32u64 | minor;
};
