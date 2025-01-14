use dev::block;
use errors::{error, errno};

// Makes an lwext4 block device for a given Bunnix block device.
export fn mkblockdev(bdev: *block::blockdev) *blockdev = {
	let buffer: []u8 = alloc([0...], bdev.blocksz)!;
	const iface = alloc(blockdev_iface {
		open = &bdev_open,
		close = &bdev_open,
		bread = &bdev_bread,
		bwrite = &bdev_bwrite,
		ph_bsize = bdev.blocksz: u32,
		ph_bcnt = bdev.blocks,
		ph_bbuf = &buffer[0],
		p_user = bdev,
		...
	})!;
	return alloc(blockdev {
		bdif = iface,
		part_offset = 0,
		part_size = bdev.blocksz * bdev.blocks,
		...
	})!;
};

fn bdev_open(bdev: *blockdev) errno = {
	return errno::NONE; // no-op
};

fn bdev_close(bdev: *blockdev) errno = {
	return errno::NONE; // no-op
};

fn bdev_bread(
	bdev: *blockdev,
	buf: *opaque,
	blk_id: u64,
	blk_cnt: u32,
) errno = {
	const bdev = bdev.bdif.p_user: *block::blockdev;
	const buf = buf: *[*]u8;
	const bytes = blk_cnt * bdev.blocksz;
	match (block::read(bdev, blk_id, buf[..bytes])) {
	case let err: error =>
		return err: errno;
	case void =>
		return errno::NONE;
	};
};

fn bdev_bwrite(
	bdev: *blockdev,
	buf: const *opaque,
	blk_id: u64,
	blk_cnt: u32,
) errno = {
	const bdev = bdev.bdif.p_user: *block::blockdev;
	const buf = buf: *[*]u8;
	const bytes = blk_cnt * bdev.blocksz;
	match (block::write(bdev, blk_id, buf[..bytes])) {
	case let err: error =>
		return err: errno;
	case void =>
		return errno::NONE;
	};
};
