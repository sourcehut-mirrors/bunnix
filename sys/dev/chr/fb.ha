use dev;
use errors::{error, errno};
use fmt;
use io;

// Framebuffer device.
export type fb = struct {
	chardev,
	phys: uintptr,
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
	// TODO: mmap goes here
	finish = &fb_finish,
	...
};

fn fb_finish(file: *io::file) void = {
	let fb = file: *fb_file;
	free(fb);
};
