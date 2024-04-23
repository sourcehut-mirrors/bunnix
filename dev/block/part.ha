use errors::{error, errno};
use log;

const partnames: []rune = [
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
];

// Partition within a block device. Special kind of block device with the
// following constraints:
//
// - blocksz and serial are copied from the parent
// - partitions is always empty
// - never added directly to the block device registry
//
// May be subtyped, e.g. blockpart_gpt
export type blockpart = struct {
	blockdev,
	bdev: *blockdev,
	partno: uint,
	lba: size,
};

// Partition scheme.
export type part_type = enum {
	UNKNOWN,
	MBR,
	GPT,
};

// Scans a block device for partitions.
export fn scanpart(bdev: *blockdev) (void | error) = {
	let partlist: []blockpart = [];
	assert(bdev.blocksz == 512); // TODO

	let buf: [512 * 2]u8 = [0...];
	read(bdev, 0, buf)?;

	const mbr = &buf[0]: *mbr;
	const gpt = &buf[512]: *gpt;
	if (gpt.magic == GPT_MAGIC) {
		bdev.part_type = part_type::GPT;
		abort("TODO: GPT");
	} else if (mbr.magic == MBR_MAGIC) {
		bdev.part_type = part_type::MBR;
		scanpart_mbr(bdev, mbr, &partlist)?;
	} else {
		bdev.part_type = part_type::UNKNOWN;
		log::kprintfln(BLOCK,
			"{}{}: unknown partition scheme (raw disk?)",
			iface_str(bdev.iface), bdev.serial);
	};

	bdev.parts = partlist;
};

const blockpart_impl = blockdev_iface {
	read = &blockpart_read,
	write = &blockpart_write,
};

fn blockpart_read(bdev: *blockdev, lba: size, buf: []u8) (void | error) = {
	abort(); // TODO
};

fn blockpart_write(bdev: *blockdev, lba: size, buf: []u8) (void | error) = {
	abort(); // TODO
};
