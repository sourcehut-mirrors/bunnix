use errors::{error, errno};
use log;

const BLOCK: str = "block";

// Block device.
export type blockdev = struct {
	impl: const *blockdev_iface,
	iface: interface,
	serial: uint,
	blocksz: size,
};

// Block device interface
export type interface = enum uint {
	SATA,
	ATAPI,
	NVME,
};

// Reads a sector from a block device. len(buf) shall be a multiple of the block
// device's block size.
export type fn_blockdev_read = fn(bdev: *blockdev, lba: size, buf: []u8) (void | error);

// Writes a sector of a block device. len(buf) shall be a multiple of the block
// device's block size.
export type fn_blockdev_write = fn(bdev: *blockdev, lba: size, buf: []u8) (void | error);

// Block device implementation.
export type blockdev_iface = struct {
	read: *fn_blockdev_read,
	write: *fn_blockdev_write,
};

let blockdevs: []*blockdev = [];

// Registers a block device on the system, initializing its serial.
export fn register(bdev: *blockdev) void = {
	static let serial: uint = 0;
	defer serial += 1;
	bdev.serial = serial;
	append(blockdevs, bdev);
	log::kprintfln(BLOCK, "Registered block device {}{}",
		iface_str(bdev.iface), bdev.serial);
};

// Returns a human-friendly representation of [[interface]].
export fn iface_str(iface: interface) const str = {
	switch (iface) {
	case interface::SATA =>
		return "sata";
	case interface::ATAPI =>
		return "atapi";
	case interface::NVME =>
		return "nvme";
	};
};
