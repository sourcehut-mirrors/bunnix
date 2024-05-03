use dev;
use errors::{error, errno};
use io;
use log;
use regex;
use strconv;
use strings;

const BLOCK = "block";
const BLOCK_RE = `^([a-zA-Z]+)([0-9]+)([a-z]*)$`;
let block_re = regex::regex { ... };
let block_re_init = false;

let blockdevs: []*blockdev = [];

// Registers a block device on the system, initializing its serial.
export fn register(bdev: *blockdev) void = {
	bdev.serial = serials[bdev.iface];
	serials[bdev.iface] += 1;

	bdev.major = switch (bdev.iface) {
	case interface::SATA =>
		yield dev::devmajor::SATA;
	case interface::ATAPI =>
		yield dev::devmajor::ATAPI;
	case interface::NVME =>
		yield dev::devmajor::NVME;
	case => abort();
	};
	bdev.major += bdev.serial: u32;
	bdev.minor = 0;

	append(blockdevs, bdev);

	log::kprintfln(BLOCK, "Registered block device {}{} ({} bytes) {}:{}",
		iface_str(bdev.iface), bdev.serial,
		bdev.blocks * bdev.blocksz,
		bdev.major, bdev.minor);

	scanpart(bdev)!;
};

// Returns all registered block devices.
export fn all() []*blockdev = {
	return blockdevs;
};

// Attempts to open a block device by name.
export fn open(name: str) (*blockdev | error) = {
	// Why the fuck am I using a regex for this
	if (!block_re_init) {
		block_re_init = true;
		block_re = regex::compile(BLOCK_RE)!;
	};

	const result = regex::find(&block_re, name);
	defer regex::result_free(result);
	if (len(result) == 0) {
		return errno::NODEV;
	};
	const iface = result[1].content;
	const serial = strconv::stou(result[2].content)!;

	let part = -1;
	if (len(result[3].content) > 1) {
		return errno::NODEV;
	} else if (len(result[3].content) != 0) {
		const rn = strings::toutf8(result[3].content)[0];
		part = (rn - 'a'): int;
	};

	const iface = str_iface(iface);
	if (iface == interface::UNKNOWN) {
		return errno::NODEV;
	};

	let bdev: nullable *blockdev = null;
	for (const cand .. blockdevs) {
		if (cand.iface != iface) {
			continue;
		};
		if (cand.serial != serial) {
			continue;
		};
		bdev = cand;
		break;
	};

	const bdev = match (bdev) {
	case null =>
		return errno::NODEV;
	case let bdev: *blockdev =>
		yield bdev;
	};

	if (part == -1) {
		return bdev;
	};

	if (part: size >= len(bdev.parts)) {
		return errno::NODEV;
	};

	return &bdev.parts[part];
};

// Populates /dev with block device nodes
export fn mknodes(root: *io::inode) (void | error) = {
	for (let bdev .. blockdevs) {
		io::inode_mknod(root, name(bdev), 0o600 | io::mode::CHR,
			dev::mkdev(bdev.major, bdev.minor))!;

		for (let part &.. bdev.parts) {
			io::inode_mknod(root, name(part), 0o600 | io::mode::CHR,
				dev::mkdev(part.major, part.minor))!;
		};
	};
};
