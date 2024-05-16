use arch;
use dev::chr;
use errors::{error, errno};
use io;
use rt;

// Basic framebuffer console suitable for pre-MMU use.
export type fb_console = struct {
	io::file,
	fb: *chr::fb,
	buffer: *[*]u32,
	row: uint,
	col: uint,
	rows: uint,
	cols: uint,
};

// Pre-MMU initialization
export fn fbcons_init(cons: *fb_console, fb: *chr::fb) void = {
	const addr = chr::fb_getphys(fb);

	*cons = fb_console {
		vtable = &fb_vtable,
		fb = fb,
		buffer = arch::phys_tokernel(addr): *[*]u32,
		cols = fb.width / (WIDTH + 1),
		rows = fb.height / HEIGHT,
		...
	};

	// Clear to black
	const length = fb.stride * fb.height;
	cons.buffer[..length] = [0...];

	chr::cons_register(cons);
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
	case '\b' =>
		if (cons.col == 0) {
			return;
		};
		cons.col -= 1;
		const x = cons.col * (WIDTH + 1);
		const y = cons.row * HEIGHT;
		fbcons_clearcell(cons, x, y);
	case =>
		const x = cons.col * (WIDTH + 1);
		const y = cons.row * HEIGHT;
		fbcons_clearcell(cons, x, y);
		fbcons_blitchar(cons, x, y, char);
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
	const fb = cons.fb;
	const wstride = fb.stride / size(u32);
	let buffer = cons.buffer;

	// Scroll buffer
	const ncopy = HEIGHT * (cons.rows - 1) * wstride;
	const start = HEIGHT * wstride;
	rt::memmove(&buffer[0], &buffer[start], ncopy * size(u32));

	// Clear out last row
	const ncopy = HEIGHT * wstride;
	const start = HEIGHT * (cons.rows - 1) * wstride;
	rt::memset(&buffer[start], 0, ncopy * size(u32));
};

fn fbcons_clearcell(cons: *fb_console, x: uint, y: uint) void = {
	const fb = cons.fb;
	let buffer = cons.buffer;
	for (let gy = 0u; gy < HEIGHT; gy += 1) {
		for (let gx = 0u; gx < WIDTH + 1; gx += 1) {
			let pixel = &buffer[(y + gy) * (fb.stride / 4) + (x + gx)];
			*pixel = 0;
		};
	};
};

type blit_op = enum {
	OVER,
	XOR,
	OR,
	AND,
};

fn fbcons_blitchar(
	cons: *fb_console,
	x: uint,
	y: uint,
	char: rune,
	op: blit_op = blit_op::OVER,
) void = {
	const fb = cons.fb;
	let buffer = cons.buffer;

	const glyph = getchar(char);
	for (let gy = 0u; gy < HEIGHT; gy += 1) {
		for (let gx = 0u; gx < WIDTH + 1; gx += 1) {
			let pixel = &buffer[(y + gy) * (fb.stride / 4) + (x + gx)];
			const mask = 1 << (WIDTH - gx);
			switch (op) {
			case blit_op::OVER =>
				if (glyph[gy] & mask != 0) {
					*pixel = 0xFFFFFFFF;
				} else {
					*pixel = 0;
				};
			case blit_op::XOR =>
				if (glyph[gy] & mask != 0) {
					*pixel ^= 0xFFFFFFFF;
				};
			case blit_op::OR =>
				if (glyph[gy] & mask != 0) {
					*pixel |= 0xFFFFFFFF;
				};
			case blit_op::AND =>
				if (glyph[gy] & mask != 0) {
					*pixel &= 0xFFFFFFFF;
				};
			};
		};
	};
};
