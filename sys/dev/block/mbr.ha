use errors::{error, errno};
use log;

// Master boot record magic number.
export def MBR_MAGIC: u16 = 0xAA55;

fn scanpart_mbr(
	bdev: *blockdev,
	mbr: *mbr,
	parts: *[]blockpart,
) (void | error) = {
	let partno = 0u;
	for (let part &.. mbr.parts) {
		if (part.parttype == 0) {
			continue;
		};
		defer partno += 1;

		assert(part.lba != 0); // TODO
		append(parts, blockpart {
			impl = &blockpart_impl,
			iface = interface::BLOCKPART,
			serial = bdev.serial,
			blocksz = bdev.blocksz,
			blocks = part.sectors,
			bdev = bdev,
			partno = partno,
			lba = part.lba,
			...
		});

		log::kprintfln(BLOCK, "{}{}{}: MBR partition {} type {}:{}",
			iface_str(bdev.iface),
			bdev.serial,
			partnames[partno],
			partno,
			part.parttype,
			mbr_parttype_name(part.parttype));
	};
};

// A master boot record.
export type mbr = struct @packed {
	bootstrap: [440]u8,
	signature: u32,
	reserved: u16,
	parts: [4]mbrpart,
	magic: u16,
};

// A master boot record partition entry.
export type mbrpart = struct {
	bootable: u8,
	start: [3]u8,
	parttype: u8,
	end: [3]u8,
	lba: u32,
	sectors: u32,
};
