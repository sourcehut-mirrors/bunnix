use endian;
use errors::{error, errno};
use log;
use uuid;

// GUID partition table magic number, "EFI PART".
def GPT_MAGIC: u64 = 0x5452415020494645;

fn scanpart_gpt(
	bdev: *blockdev,
	gpt: *gpt,
	parts: *[]blockpart,
) (void | error) = {
	let partno = 0u;

	const iter = gpt_iterpart(bdev, gpt)?;
	for (const part => gpt_nextpart(&iter)?) {
		if (uuid::compare(part.parttype, uuid::nil)) {
			continue;
		};

		defer partno += 1;
		append(parts, blockpart {
			impl = &blockpart_impl,
			iface = interface::BLOCKPART,
			serial = bdev.serial,
			major = bdev.major,
			minor = partno + 1,
			blocksz = bdev.blocksz,
			blocks = part.end_lba - part.start_lba,
			bdev = bdev,
			partno = partno,
			lba = part.start_lba,
			...
		})!;

		log::kprintfln(BLOCK, "{}{}{}: GPT partition {}: {}",
			iface_str(bdev.iface),
			bdev.serial,
			partnames[partno],
			partno,
			uuid::encodestr(part.partuuid));
	};
};

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

export type gpt_iter = struct {
	gpt: *gpt,
	bdev: *blockdev,
	lba: u64,
	partno: u32,
	buf: []u8,
};

// Returns an iterator for the partitions available in a GPT. The [[gpt]] object
// is borrowed for the lifetime of the iterator. The user must iterate over the
// entire iterator to ensure that resources are freed once complete.
export fn gpt_iterpart(bdev: *blockdev, gpt: *gpt) (gpt_iter | error) = {
	assert(bdev.blocksz == 512); // TODO
	static let buf: [512]u8 = [0...];
	read(bdev, gpt.part_lba, buf)?;

	return gpt_iter {
		gpt = gpt,
		bdev = bdev,
		lba = gpt.part_lba,
		partno = 0,
		buf = buf,
	};
};

// Returns the next partition from a GPT, or void. The return value is borrowed
// from the iterator.
export fn gpt_nextpart(iter: *gpt_iter) (*gptpart | error | done) = {
	if (iter.partno > iter.gpt.npart) {
		return done;
	};

	const offs = iter.partno * iter.gpt.partsz;
	const lba_offs = offs / 512;
	const buf_offs = offs % 512;

	const lba = iter.gpt.part_lba + offs / 512;
	if (lba != iter.lba) {
		read(iter.bdev, lba, iter.buf)?;
		iter.lba = lba;
	};

	let part = &iter.buf[buf_offs]: *gptpart;
	uuidconv(part.parttype);
	uuidconv(part.partuuid);
	iter.partno += 1;
	return part;
};

fn uuidconv(uuid: []u8) void = {
	const tlow = endian::begetu32(uuid[0..]);
	endian::leputu32(uuid[0..], tlow);
	const tmid = endian::begetu16(uuid[4..]);
	endian::leputu16(uuid[4..], tmid);
	const thigh = endian::begetu16(uuid[6..]);
	endian::leputu16(uuid[6..], thigh);
};
