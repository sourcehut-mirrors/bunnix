use arch;
use boot;
use errors::{error, errno};
use io;
use mman;
use rt;
use types;

export type fb_console = struct {
	io::file,
	front: uintptr,
	back: uintptr,
	width: uint,
	height: uint,
	stride: uint,
	row: uint,
	col: uint,
	rows: uint,
	cols: uint,
	damage: struct {
		x: uint,
		y: uint,
		w: uint,
		h: uint,
	},
};

// Pre-MMU initialization
export fn fbcons_init(cons: *fb_console, fb: *boot::bootfb) void = {
	*cons = fb_console {
		vtable = &fb_vtable,
		front = arch::phys_tokernel(fb.fb_base): uintptr,
		back = arch::phys_tokernel(fb.fb_base): uintptr,
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
	rt::memset(cons.back: *opaque, 0, fb.fb_size);
};

// Post-MMU initialization
export fn fbcons_lateinit(cons: *fb_console) void = {
	assert(cons.front == cons.back);

	const length = cons.stride * cons.height;
	const front_phys = arch::kernel_tophys(cons.front: *opaque);
	const front = mman::mmap(&mman::kernel,
		front_phys, 0, length,
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::WT)!;
	const back = mman::mmap(&mman::kernel, 0, 0, length,
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON)!;

	// Copy the current screen contents into the back buffer
	const front_data = front: *[*]u8;
	const back_data = back: *[*]u8;
	back_data[..length] = front_data[..length];

	cons.front = front;
	cons.back = back;
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
	fbcons_present(cons);
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
		const x = cons.col * (WIDTH + 1);
		const y = cons.row * HEIGHT;
		fbcons_blitchar(cons, x, y, char);
		fbcons_damage(cons, x, y, WIDTH, HEIGHT);
		cons.col += 1;
	};
	if (cons.col >= cons.cols) {
		cons.col = 0;
		cons.row += 1;
	};
	if (cons.row >= cons.rows) {
		cons.row = cons.rows - 1;
		fbcons_scroll(cons);
	};
};

fn fbcons_scroll(cons: *fb_console) void = {
	let buffer = cons.back: *[*]u32;
	const wstride = cons.stride / size(u32);

	// Scroll buffer
	const ncopy = HEIGHT * (cons.rows - 1) * wstride;
	const start = HEIGHT * wstride;
	rt::memmove(&buffer[0], &buffer[start], ncopy * size(u32));

	// Clear out last row
	const ncopy = HEIGHT * wstride;
	const start = HEIGHT * (cons.rows - 1) * wstride;
	rt::memset(&buffer[start], 0, ncopy * size(u32));

	fbcons_damage(cons, 0, 0, cons.width, cons.height);
};

fn fbcons_blitchar(cons: *fb_console, x: uint, y: uint, char: rune) void = {
	let buffer = cons.back: *[*]u32;
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

fn fbcons_damage(cons: *fb_console, x: uint, y: uint, w: uint, h: uint) void = {
	let d = &cons.damage;
	if (d.x == types::UINT_MAX || d.y == types::UINT_MAX) {
		d.x = x;
		d.y = y;
		d.w = w;
		d.h = h;
		return;
	};

	const x1 = if (d.x < x) d.x else x;
	const x2 = if (d.x + d.w < x + w) x + w else d.x + d.w;
	const y1 = if (d.y < y) d.y else y;
	const y2 = if (d.y + d.h < y + h) y + h else d.y + d.h;

	d.x = x1;
	d.y = y1;
	d.w = x2 - x1;
	d.h = y2 - y1;
};

fn fbcons_present(cons: *fb_console) void = {
	if (cons.front == cons.back) {
		return;
	};

	let dmg = &cons.damage;
	if (dmg.w == 0 || dmg.h == 0) {
		return;
	};

	let back = cons.back: *[*]u32;
	let front = cons.front: *[*]u32;
	for (let y = dmg.y; y < dmg.y + dmg.h; y += 1) {
		const row_ix = y * (cons.stride / 4);
		const start = row_ix + dmg.x;
		const end = row_ix + dmg.x + dmg.w;
		front[start..end] = back[start..end];
	};

	dmg.x = types::UINT_MAX;
	dmg.y = types::UINT_MAX;
	dmg.w = 0;
	dmg.h = 0;
};
