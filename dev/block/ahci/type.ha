def SATA_SIG_ATA: u32 = 0x00000101;
def SATA_SIG_ATAPI: u32 = 0xEB140101;
def SATA_SIG_SEMB: u32 = 0xC33C0101;
def SATA_SIG_PM: u32 = 0x96690101;

def ATA_DEV_BUSY: u8 = 0x80;
def ATA_DEV_DRQ: u8 = 0x08;

export type devtype = enum {
	NULL,
	SATA,
	SEMB,
	PM,
	SATAPI,
};

// Converts an AHCI [[devtype]] to a string.
export fn devtype_str(dt: devtype) const str = {
	switch (dt) {
	case devtype::NULL =>
		return "NULL";
	case devtype::SATA =>
		return "SATA";
	case devtype::SEMB =>
		return "SEMB";
	case devtype::PM =>
		return "PM";
	case devtype::SATAPI =>
		return "SATAPI";
	};
};

