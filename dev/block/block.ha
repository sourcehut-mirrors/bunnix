use errors::{error, errno};
use log;

const BLOCK: str = "block";

// Block device.
export type blockdev = struct {
	impl: const *blockdev_iface,
	iface: interface,
	serial: uint,
	blocksz: size,
	blocks: size,
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
	bdev.serial = serials[bdev.iface];
	serials[bdev.iface] += 1;
	append(blockdevs, bdev);
	log::kprintfln(BLOCK, "Registered block device {}{} ({} bytes)",
		iface_str(bdev.iface), bdev.serial,
		bdev.blocks * bdev.blocksz);
};

// Returns all registered block devices.
export fn all() []*blockdev = {
	return blockdevs;
};

// Reads a sector from a block device. len(buf) shall be a multiple of the block
// device's block size.
export fn read(bdev: *blockdev, lba: size, buf: []u8) (void | error) = {
	return bdev.impl.read(bdev, lba, buf);
};

// Writes a sector of a block device. len(buf) shall be a multiple of the block
// device's block size.
export fn write(bdev: *blockdev, lba: size, buf: []u8) (void | error) = {
	return bdev.impl.write(bdev, lba, buf);
};
