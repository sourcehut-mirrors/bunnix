use arch;
use dev::chr;
use rt;

export type pixbuf = struct {
	fb: nullable *chr::fb,
	data: nullable *[*]u32,
};

// Initializes an identity-mapped pixel buffer for the given fb.
fn pixbuf_init_ident(buf: *pixbuf, fb: *chr::fb) void = {
	const addr = chr::fb_getphys(fb);
	buf.data = arch::phys_tokernel(addr): *[*]u32;
	buf.fb = fb;
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
	for (let gy = 0u; gy < HEIGHT; gy += 1) {
		for (let gx = 0u; gx < WIDTH + 1; gx += 1) {
			let pixel = &data[(y + gy) * (fb.stride / 4) + (x + gx)];
			const mask = 1 << (WIDTH - gx);
			if (glyph[gy] & mask != 0) {
				blitop(pixel, color, op);
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
