use arch;
use boot;
use errors::{error, errno};
use io;
use rt;

export type fb_console = struct {
	io::file,
	fb_base: uintptr,
	width: uint,
	height: uint,
	stride: uint,
	row: uint,
	col: uint,
	rows: uint,
	cols: uint,
};

export fn fbcons_init(cons: *fb_console, fb: *boot::bootfb) void = {
	*cons = fb_console {
		vtable = &fb_vtable,
		fb_base = arch::phys_tokernel(fb.fb_base): uintptr,
		width = fb.width,
		height = fb.height,
		stride = fb.stride,
		row = 0,
		col = 0,
		cols = fb.width / (WIDTH + 1): u32,
		rows = fb.height / HEIGHT: u32,
		...
	};

	// Clear to black
	rt::memset(cons.fb_base: *opaque, 0, fb.fb_size);
};

const fb_vtable = io::vtable {
	write = &fbcons_write,
	...
};

fn fbcons_write(file: *io::file, buf: const []u8) (size | error) = {
	let cons = file: *fb_console;
	for (let i = 0z; i < len(buf); i += 1) {
		fbcons_putc(cons, buf[i]: rune);
	};
	return len(buf);
};

fn fbcons_putc(cons: *fb_console, char: rune) void = {
	switch (char) {
	case '\n' =>
		cons.row += 1;
		cons.col = 0;
	case '\r' =>
		cons.col = 0;
	case '\t' =>
		cons.col += 8 - cons.col % 8;
	case =>
		fbcons_blitchar(cons,
			cons.col * (WIDTH + 1),
			cons.row * HEIGHT,
			char);
		cons.col += 1;
	};
	if (cons.col >= cons.cols) {
		cons.col = 0;
		cons.row += 1;
	};
	if (cons.row >= cons.rows) {
		cons.row = 0; // TODO: Scroll
	};
};

fn fbcons_blitchar(cons: *fb_console, x: uint, y: uint, char: rune) void = {
	let buffer = cons.fb_base: *[*]u32;
	const glyph = getchar(char);

	for (let gy = 0u; gy < HEIGHT; gy += 1) {
		for (let gx = 0u; gx < WIDTH + 1; gx += 1) {
			let pixel = &buffer[(y + gy) * (cons.stride / 4) + (x + gx)];
			const mask = 1 << (WIDTH - gx);
			if (glyph[gy] & mask != 0) {
				*pixel = 0xFFFFFFFF;
			} else {
				*pixel = 0;
			};
		};
	};
};
