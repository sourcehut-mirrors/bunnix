use uuid;

// GUID partition table magic number, "EFI PART".
def GPT_MAGIC: u64 = 0x5452415020494645;

// GUID partition table.
export type gpt = struct {
	magic: u64,
	rev: u32,
	headersz: u32,
	crc: u32,
	reserved: u32,
	header_lba: u64,
	alt_lba: u64,
	first_block_lba: u64,
	last_block_lba: u64,
	uuid: uuid::uuid,
	part_lba: u64,
	npart: u32,
	partsz: u32,
	part_crc: u32,
};

// A GPT partition.
export type gptpart = struct {
	parttype: uuid::uuid,
	partuuid: uuid::uuid,
	start_lba: u64,
	end_lba: u64,
	attrs: u64,
	partname: [36]u16,
};
