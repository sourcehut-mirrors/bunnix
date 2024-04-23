use errors::{error, errno};
use dev::block;

const bdev_impl = block::blockdev_iface {
	read = &bdev_readsectors,
	write = &bdev_writesectors,
};

fn bdev_readsectors(
	bdev: *block::blockdev,
	lba: size,
	buf: []u8,
) (void | error) = {
	abort(); // TODO
};

fn bdev_writesectors(
	bdev: *block::blockdev,
	lba: size,
	buf: []u8,
) (void | error) = {
	abort(); // TODO
};
