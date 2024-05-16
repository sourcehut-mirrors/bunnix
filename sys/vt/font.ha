let @symbol("_binary_vt_alt_8x16_start") font_data: [*]u8;

export def FONT_WIDTH: uint = 9;
export def FONT_HPAD: uint = 1;
export def FONT_HEIGHT: uint = 16;

// TODO: Map some non-ascii characters
def FALLBACK: u8 = 254; // ■

// Returns a single 8x16 character.
export fn getchar(rn: rune) []u8 = {
	const rn = rn: u32;
	if (rn > 127) {
		rn = FALLBACK;
	};
	rn = rn: u8;
	const start = rn * 16, end = (rn + 1) * 16;
	return font_data[start..end];
};
