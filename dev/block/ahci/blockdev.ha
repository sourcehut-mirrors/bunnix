// TODO: async block API
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
	const bdev = bdev: *ahci_port;
	assert(len(buf) % SECTORSZ == 0);

	const hba = bdev.base;
	const buffer = getbuffer(hba.pool, len(buf))!;
	defer releasebuffer(hba.pool, &buffer);

	// TODO: kick back to caller? transparently do multiple reads?
	const nbyte = len(buf);
	assert(nbyte < buffer.prdt.1);

	let cmd = prep_read_dma_ext(bdev, lba, buffer.prdt)!;
	port_wait(bdev);
	port_submitcmd(bdev, cmd);
	port_waitcmd(bdev, cmd);

	const _is = bdev.port._is;
	bdev.port._is = _is;
	assert(_is & HBA_PxIS_TFES == 0);

	buf[..nbyte] = buffer.data[..nbyte];
};

fn bdev_writesectors(
	bdev: *block::blockdev,
	lba: size,
	buf: []u8,
) (void | error) = {
	abort(); // TODO
};
