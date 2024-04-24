use errors::{error, errno};

// Block device.
export type blockdev = struct {
	impl: const *blockdev_iface,
	iface: interface,
	serial: uint,
	blocksz: size,
	blocks: size,
	part_type: part_type,
	parts: []blockpart,
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
