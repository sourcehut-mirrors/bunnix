export type fis_type = enum u8 {
	REG_H2D		= 0x27,	// Register FIS - host to device
	REG_D2H		= 0x34,	// Register FIS - device to host
	DMA_ACT		= 0x39,	// DMA activate FIS - device to host
	DMA_SETU	= 0x41,	// DMA setup FIS - bidirectional
	DATA		= 0x46,	// Data FIS - bidirectional
	BIST		= 0x58,	// BIST activate FIS - bidirectional
	PIO_SETUP	= 0x5F,	// PIO setup FIS - device to host
	DEV_BITS	= 0xA1,	// Set device bits FIS - device to host
};

export type fis_reg_h2d = struct {
	fis_type: u8,
	pmport_c: u8, // pmport + command/control
	command: u8,
	featurel: u8,
	lba0: u8,
	lba1: u8,
	lba2: u8,
	device: u8,
	lba3: u8,
	lba4: u8,
	lba5: u8,
	featureh: u8,
	countl: u8,
	counth: u8,
	icc: u8,
	control: u8,
	rsv1: [4]u8,
};

export type fis_reg_d2h = struct {
	fis_type: u8,
	pmport_i: u8, // port multiplier + interrupt bit
	status: u8,
	error: u8,
	lba0: u8,
	lba1: u8,
	lba2: u8,
	device: u8,
	lba3: u8,
	lba4: u8,
	lba5: u8,
	rsv2: u8,
	countl: u8,
	counth: u8,
	rsv3: [2]u8,
	rsv4: [5]u8,
};

export type fis_data = struct {
	fis_type: u8,
	pmport: u8,
	rsv1: [2]u8,
	data: [*]u32,
};

export type fis_pio_setup = struct {
	fis_type: u8,
	pmport_d_i: u8, // port multiplier + direction + interrupt bit
	status: u8,
	error: u8,
	lba0: u8,
	lba1: u8,
	lba2: u8,
	device: u8,
	lba3: u8,
	lba4: u8,
	lba5: u8,
	rsv2: u8,
	countl: u8,
	counth: u8,
	rsv3: u8,
	e_status: u8,
	tc: u16,
	rsv4: [2]u8,
};

export type fis_dma_setup = struct {
	fis_type: u8,
	pmport_d_i_a: u8, // port multiplier + direction + interrupt + auto
	rsv1: [2]u8,
	dmabuf_id: u64,
	rsv2: u32,
	dmabuf_offs: u32,
	transfer_count: u32,
	rsv3: u32,
};
