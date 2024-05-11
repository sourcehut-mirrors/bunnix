use errors::{error, errno};
use io;

// Opens a block device as an [[io::file]].
export fn openfile(bdev: *blockdev) *io::file = {
	return alloc(blockfile {
		vtable = &block_file_impl,
		bdev = bdev,
		...
	});
};

type blockfile = struct {
	io::file,
	bdev: *blockdev,
	pos: size,
};

const block_file_impl = io::vtable {
	read = &blockfile_read,
	write = &blockfile_write,
	seek = &blockfile_seek,
	finish = &blockfile_finish,
	...
};

fn blockfile_read(file: *io::file, buf: []u8) (size | io::EOF | error) = {
	const file = file: *blockfile;
	const bdev = file.bdev;
	const blksz = bdev.blocksz;

	let nread = len(buf);
	if (file.pos + nread > bdev.blocks * blksz) {
		nread = (bdev.blocks * blksz) - file.pos;
	};
	if (nread == 0) {
		return io::EOF;
	};

	assert(blksz == 512);
	let block: [512]u8 = [0...]; // TODO: do this better
	let lba = file.pos / blksz;
	let offs = file.pos % blksz;
	let amt = 0z;
	for (amt < nread) {
		let ncopy = len(buf) - amt;
		if (ncopy > len(block) - offs) {
			ncopy = len(block) - offs;
		};

		read(bdev, lba, block)?;
		buf[amt..amt+ncopy] = block[offs..offs+ncopy];

		offs = 0;
		lba += 1;
		amt += ncopy;
	};

	return nread;
};

fn blockfile_write(file: *io::file, buf: const []u8) (size | error) = {
	const file = file: *blockfile;
	const bdev = file.bdev;
	const blksz = bdev.blocksz;

	let nwrite = len(buf);
	if (file.pos + nwrite > bdev.blocks * blksz) {
		nwrite = (bdev.blocks * blksz) - file.pos;
	};
	if (nwrite == 0) {
		return errno::NOSPC: error;
	};

	assert(blksz == 512);
	let block: [512]u8 = [0...]; // TODO: do this better
	let lba = file.pos / blksz;
	let offs = file.pos % blksz;
	let amt = 0z;
	for (amt < nwrite) {
		let ncopy = len(buf) - amt;
		if (ncopy > len(block) - offs) {
			ncopy = len(block) - offs;
		};

		if (offs > 0 || ncopy < blksz) {
			read(bdev, lba, block)?;
		};

		block[offs..offs+ncopy] = buf[amt..amt+ncopy];
		write(bdev, lba, block)?;

		offs = 0;
		lba += 1;
		amt += ncopy;
	};

	return nwrite;
};

fn blockfile_seek(file: *io::file, offs: i64, w: io::whence) (i64 | error) = {
	let fd = file: *blockfile;
	const max = fd.bdev.blocksz * fd.bdev.blocks;
	let start = switch (w) {
	case io::whence::SET => yield 0z;
	case io::whence::CUR => yield fd.pos;
	case io::whence::END => yield max;
	};
	if (offs < 0) {
		if (start < (-offs): size) {
			return errno::INVAL: error;
		};
	} else {
		if (max - start < offs: size) {
			return errno::INVAL: error;
		};
	};
	fd.pos = start + offs: size;
	return fd.pos: i64;
};

fn blockfile_finish(file: *io::file) void = {
	free(file);
};
