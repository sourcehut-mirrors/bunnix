use arch;
use dev::chr;
use mman;
use rt;

export type pixbuf = struct {
	fb: nullable *chr::fb,
	data: nullable *[*]u32,
};

export type rect = struct {
	x: uint,
	y: uint,
	w: uint,
	h: uint,
};

// Initializes an identity-mapped pixel buffer for the given fb.
fn pixbuf_init_ident(buf: *pixbuf, fb: *chr::fb) void = {
	const addr = chr::fb_getphys(fb);
	buf.data = arch::phys_tokernel(addr): *[*]u32;
	buf.fb = fb;
};

// Initializes a pixel buffer by memory-mapping a framebuffer into the kernel.
fn pixbuf_init_mapped(buf: *pixbuf, fb: *chr::fb) void = {
	const data = chr::fb_map(fb, &mman::kernel, 0,
		mman::prot::READ | mman::prot::WRITE)!: *[*]u32;
	buf.data = data;
	buf.fb = fb;
};

// Initializes a memory-backed backbuffer for a framebuffer.
fn pixbuf_init_back(buf: *pixbuf, fb: *chr::fb) void = {
	const length = fb.stride * fb.height;
	const data = mman::mmap(&mman::kernel, 0, 0, length,
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON)!: *[*]u32;
	buf.data = data;
	buf.fb = fb;
};

fn pixbuf_copy(dest: *pixbuf, src: const *pixbuf) void = {
	const fb = dest.fb as *chr::fb;
	const src_data = src.data as *[*]u32;
	const dest_data = dest.data as *[*]u32;
	const length = (fb.stride * fb.height) / size(u32);
	dest_data[..length] = src_data[..length];
};

fn pixbuf_copyrect(
	dest: *pixbuf,
	src: const *pixbuf,
	rect: const *rect,
) void = {
	const fb = dest.fb as *chr::fb;
	let dest = dest.data as *[*]u32;
	let src = src.data as *[*]u32;
	for (let y = rect.y; y < rect.y + rect.h; y += 1) {
		const row_ix = y * (fb.stride / 4);
		const start = row_ix + rect.x;
		const end = row_ix + rect.x + rect.w;
		dest[start..end] = src[start..end];
	};
};

fn pixbuf_clear(buf: *pixbuf) void = {
	const fb = buf.fb as *chr::fb;
	let data = buf.data as *[*]u32;

	const length = (fb.stride * fb.height) / size(u32);
	data[..length] = [0...];
};

type blit_op = enum {
	OVER,
	XOR,
	OR,
	AND,
};

fn blitop(dest: *u32, src: u32, op: blit_op) void = {
	switch (op) {
	case blit_op::OVER =>
		*dest = src;
	case blit_op::XOR =>
		*dest ^= src;
	case blit_op::OR =>
		*dest |= src;
	case blit_op::AND =>
		*dest &= src;
	};
};

fn blitchar(
	buf: *pixbuf,
	x: uint,
	y: uint,
	char: rune,
	color: u32 = 0xFFFFFFFF,
	op: blit_op = blit_op::OVER,
) void = {
	const fb = buf.fb as *chr::fb;
	let data = buf.data as *[*]u32;

	const glyph = getchar(char);
	for (let gy = 0u; gy < FONT_HEIGHT; gy += 1) {
		for (let gx = 0u; gx < FONT_WIDTH; gx += 1) {
			let pixel = &data[(y + gy) * (fb.stride / 4) + (x + gx)];
			const mask = 1 << (FONT_WIDTH - FONT_HPAD - gx);
			if (glyph[gy] & mask != 0) {
				blitop(pixel, color, op);
			} else {
				blitop(pixel, 0, op);
			};
		};
	};
};

fn blitrect(
	buf: *pixbuf,
	x: uint,
	y: uint,
	w: uint,
	h: uint,
	color: u32 = 0,
) void = {
	const fb = buf.fb as *chr::fb;
	let data = buf.data as *[*]u32;

	// TODO: this could be more efficient
	for (let gy = 0u; gy < h; gy += 1)
	for (let gx = 0u; gx < w + 1; gx += 1) {
		let pixel = &data[(y + gy) * (fb.stride / 4) + (x + gx)];
		blitop(pixel, color, blit_op::OVER);
	};
};

fn scroll(
	buf: *pixbuf,
	pixels: uint,
) void = {
	const fb = buf.fb as *chr::fb;
	const wstride = fb.stride / size(u32);
	let data = buf.data as *[*]u32;

	// Scroll buffer
	const ncopy = (fb.height - pixels) * wstride;
	const start = pixels * wstride;
	rt::memmove(&data[0], &data[start], ncopy * size(u32));

	// Clear out last row
	const ncopy = pixels * wstride;
	const start = (fb.height - pixels) * wstride;
	rt::memset(&data[start], 0, ncopy * size(u32));
};
