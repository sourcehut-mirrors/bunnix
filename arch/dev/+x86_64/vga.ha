use arch::x86_64;
use errors::{error, errno};
use io;

// Number of rows in the VGA console.
export def VGA_ROWS: size = 25;

// Number of columns in the VGA console.
export def VGA_COLS: size = 80;

// Number of cells in the VGA console.
export def VGA_CELLS: size = VGA_ROWS * VGA_COLS;

// Physical address of the VGA console buffer.
export const VGA_CONSBASE: *[VGA_CELLS]u16 = 0xb8000: uintptr: *[VGA_CELLS]u16;

export type vga_console = struct {
	io::file,
	base: nullable *[VGA_CELLS]u16,
	row: uint,
	col: uint,
};

// VGA text console color codes.
export type vga_color = enum u8 {
	BLACK = 0,
	BLUE = 1,
	GREEN = 2,
	CYAN = 3,
	RED = 4,
	MAGENTA = 5,
	BROWN = 6,
	LIGHT_GREY = 7,
	DARK_GREY = 8,
	LIGHT_BLUE = 9,
	LIGHT_GREEN = 10,
	LIGHT_CYAN = 11,
	LIGHT_RED = 12,
	LIGHT_MAGENTA = 13,
	LIGHT_BROWN = 14,
	WHITE = 15,
};

// Initializes a new VGA console.
export fn vga_init(cons: *vga_console, base: *[VGA_CELLS]u16) void = {
	*cons = vga_console {
		vtable = &vga_vtable,
		base = base,
		...
	};
	curdisable();
	initpos(cons);
};

const vga_vtable = io::vtable {
	write = &vga_write,
	...
};

fn curdisable() void = {
	x86_64::outb(0x3D4, 0x0A);
	x86_64::outb(0x3D5, 0x20);
};

fn initpos(cons: *vga_console) void = {
	let last = VGA_ROWS - 1;
	let base = cons.base: *[VGA_ROWS * VGA_COLS]u16;
	for (let row = VGA_ROWS - 1; row > 0; row -= 1) {
		let empty = true;
		for (let col = 0z; col < VGA_COLS; col += 1) {
			const val = base[(row - 1) * VGA_COLS + col] & 0xFF;
			if (val != 0 && val != ' ') {
				empty = false;
				break;
			};
		};
		if (!empty) {
			last = row;
			break;
		};
	};
	cons.row = last: uint;
};

fn mkcell(rn: u8, bg: vga_color, fg: vga_color) u16 = {
	return rn: u16 | (fg | bg << 4): u16 << 8;
};

fn vga_putc(cons: *vga_console, rn: u8) void = {
	let base = cons.base: *[VGA_ROWS * VGA_COLS]u16;
	switch (rn) {
	case '\n' =>
		cons.row += 1;
		cons.col = 0;
	case '\r' =>
		cons.col = 0;
	case '\t' =>
		cons.col += 8 - cons.col % 8;
	case =>
		const val = mkcell(rn, vga_color::BLACK, vga_color::LIGHT_GREY);
		base[cons.row * VGA_COLS + cons.col] = val;
		cons.col += 1;
	};
	if (cons.col >= VGA_COLS) {
		cons.row += 1;
		cons.col = 0;
	};
	if (cons.row >= VGA_ROWS) {
		const last_row = (VGA_ROWS - 1) * VGA_COLS;
		const empty =
			mkcell(' ', vga_color::BLACK, vga_color::LIGHT_GREY);
		base[..last_row] = base[VGA_COLS..VGA_COLS + last_row];
		for (let i = last_row; i < VGA_ROWS * VGA_COLS; i += 1) {
			base[i] = empty;
		};
		cons.row -= 1;
	};
};

fn vga_write(cons: *io::file, buf: const []u8) (size | error) = {
	let cons = cons: *vga_console;
	assert(cons.vtable == &vga_vtable);
	for (let i = 0z; i < len(buf); i += 1) {
		vga_putc(cons, buf[i]);
	};
	return len(buf);
};
