use dev;
use errors::{error, errno};
use fmt;
use io;
use mman;

// Framebuffer device.
export type fb = struct {
	chardev,
	addr: uintptr,
	width: uint,
	height: uint,
	stride: uint,
	format: pixel_format,
};

// Framebuffer pixel format.
export type pixel_format = enum uint {
	RGBX8,
	BGRX8,
};

let fbs: []*fb = [];

// Initialize a framebuffer device.
export fn fb_init(dev: *fb) void = {
	static let nfb = 0u32;

	dev.iface = &fb_chardev_impl;

	dev.major = dev::FB_MAJOR;
	dev.minor = nfb;
	nfb += 1;

	register(dev);

	if (len(fbs) == 0) {
		static let buf: [8]*fb = [null: *fb...];
		fbs = buf[..0];
	};
	static append(fbs, dev);
};

// Returns the underlying physical memory address of this framebuffer.
export fn fb_getphys(dev: *fb) uintptr = {
	return dev.addr;
};

// Maps a framebuffer device into a virtual memory manager.
export fn fb_map(
	dev: *fb,
	vmm: *mman::vmm,
	vaddr: uintptr,
	prot: mman::prot,
) (uintptr | error) = {
	const addr = dev.addr;
	const length = dev.stride * dev.height;
	return mman::mmap(vmm, addr, 0, length, prot,
		mman::flag::WT | mman::flag::CD)!;
};

// Populates /dev with framebuffer devices
export fn mountfb(root: *io::inode) void = {
	let namebuf: [32]u8 = [0...];
	for (let fb .. fbs) {
		const name = fmt::bsprintf(namebuf, "fb{}", fb.minor);

		io::inode_mknod(root, name, 0o660 | io::mode::CHR,
			dev::mkdev(fb.major, fb.minor))!;
	};
};

const fb_chardev_impl = chardev_iface {
	open = &fb_open,
};

fn fb_open(cdev: *chardev) (*io::file | error) = {
	let dev = cdev: *fb;
	return alloc(fb_file {
		vtable = &fb_file_impl,
		dev = dev,
		...
	});
};

type fb_file = struct {
	io::file,
	dev: *fb,
};

const fb_file_impl = io::vtable {
	ioctl = &fb_ioctl,
	mmap = &fb_mmap,
	finish = &fb_finish,
	...
};

type screeninfo = struct {
	width: uint,
	height: uint,
	stride: uint,
	format: pixel_format,
};

fn fb_ioctl(file: *io::file, req: uint, arg: u64) (u64 | error) = {
	let file = file: *fb_file;
	let fb = file.dev;

	switch (req) {
	case io::FBIOGET_VSCREENINFO =>
		let info = arg: uintptr: *screeninfo;
		if (!mman::isvalid(info, size(screeninfo), true)) {
			return errno::FAULT: error;
		};
		*info = screeninfo {
			width = fb.width,
			height = fb.height,
			stride = fb.stride,
			format = fb.format,
		};
		return 0u64;
	case =>
		return errno::INVAL: error;
	};
};

fn fb_mmap(
	file: *io::file,
	vmm: *opaque,
	addr: uintptr,
	length: size,
	prot: int,
	flags: int,
	offs: i64,
) (uintptr | error) = {
	const file = file: *fb_file;
	const fb = file.dev;
	if (length > fb.height * fb.stride) {
		return errno::INVAL;
	};

	const flag = flags: mman::flag
		| mman::flag::WT
		| mman::flag::CD
		| mman::flag::USER;
	return mman::mmap(vmm: *mman::vmm,
		fb.addr, addr, length,
		prot: mman::prot, flag);
};

fn fb_finish(file: *io::file) void = {
	let fb = file: *fb_file;
	free(fb);
};
