use arch::x86_64;

def VGA_CONS: *[*]u16 = 0xb8000: uintptr: *[*]u16;
def VGA_ROWS: size = 25;
def VGA_COLS: size = 80;

type vga_console = struct {
	row: uint,
	col: uint,
};

let cons: vga_console = vga_console { ... };

type vga_color = enum u8 {
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

@init fn init() void = {
	// Disable cursor
	x86_64::outb(0x3D4, 0x0A);
	x86_64::outb(0x3D5, 0x20);

	// Don't overwrite any earlier VGA text
	let last = VGA_ROWS - 1;
	for (let row = VGA_ROWS - 1; row > 0; row -= 1) {
		let empty = true;
		for (let col = 0z; col < VGA_COLS; col += 1) {
			const val = VGA_CONS[(row - 1) * VGA_COLS + col] & 0xFF;
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

fn vga_mkcell(rn: u8, bg: vga_color, fg: vga_color) u16 = {
	return rn: u16 | (fg | bg << 4): u16 << 8;
};

fn vga_putc(rn: u8) void = {
	switch (rn) {
	case '\n' =>
		cons.row += 1;
		cons.col = 0;
	case '\r' =>
		cons.col = 0;
	case =>
		const val = vga_mkcell(rn, vga_color::BLACK, vga_color::LIGHT_GREY);
		VGA_CONS[cons.row * VGA_COLS + cons.col] = val;
		cons.col += 1;
		if (cons.col >= VGA_COLS) {
			cons.row += 1;
			cons.col = 0;
		};
	};
};

fn vga_write(buf: []u8) void = {
	for (let i = 0z; i < len(buf); i += 1) {
		vga_putc(buf[i]);
	};
};
