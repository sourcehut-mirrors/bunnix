// See vterm.h

use types::c;

export type VTerm = opaque;
export type VTermState = opaque;
export type VTermScreen = opaque;

export def VTERM_MAX_CHARS_PER_CELL = 6;

export type VTermPos = struct {
	row: int,
	col: int,
};

export type VTermRect = struct {
	start_row: int,
	end_row: int,
	start_col: int,
	end_col: int,
};

export type VTermColorType = enum u8 {
	VTERM_COLOR_RGB = 0x00,
	VTERM_COLOR_INDEXED = 0x01,
	VTERM_COLOR_TYPE_MASK = 0x01,
	VTERM_COLOR_DEFAULT_FG = 0x02,
	VTERM_COLOR_DEFAULT_BG = 0x04,
	VTERM_COLOR_DEFAULT_MASK = 0x06
};

export type VTermColor = union {
	_type: u8,
	rgb: struct {
		_type: u8,
		red: u8,
		green: u8,
		blue: u8,
	},
	indexed: struct {
		_type: u8,
		idx: u8,
	},
};

export type VTermValueType = enum {
	VTERM_VALUETYPE_BOOL = 1,
	VTERM_VALUETYPE_INT,
	VTERM_VALUETYPE_STRING,
	VTERM_VALUETYPE_COLOR,

	VTERM_N_VALUETYPES,
};

export type VTermStringFragment = struct {
	string: const *c::char,
	// Bits 0-30: length; 31: initial; 32: final
	ln_flags: size,
};

export type VTermValue = union {
	boolean: int,
	number: int,
	string: VTermStringFragment,
	color: VTermColor,
};

export type VTermAttr = enum {
	VTERM_ATTR_BOLD = 1,   // bool:   1, 22
	VTERM_ATTR_UNDERLINE,  // number: 4, 21, 24
	VTERM_ATTR_ITALIC,     // bool:   3, 23
	VTERM_ATTR_BLINK,      // bool:   5, 25
	VTERM_ATTR_REVERSE,    // bool:   7, 27
	VTERM_ATTR_CONCEAL,    // bool:   8, 28
	VTERM_ATTR_STRIKE,     // bool:   9, 29
	VTERM_ATTR_FONT,       // number: 10-19
	VTERM_ATTR_FOREGROUND, // color:  30-39 90-97
	VTERM_ATTR_BACKGROUND, // color:  40-49 100-107
	VTERM_ATTR_SMALL,      // bool:   73, 74, 75
	VTERM_ATTR_BASELINE,   // number: 73, 74, 75
	VTERM_N_ATTRS,
};

export type VTermProp = enum {
	VTERM_PROP_CURSORVISIBLE = 1, // bool
	VTERM_PROP_CURSORBLINK,       // bool
	VTERM_PROP_ALTSCREEN,         // bool
	VTERM_PROP_TITLE,             // string
	VTERM_PROP_ICONNAME,          // string
	VTERM_PROP_REVERSE,           // bool
	VTERM_PROP_CURSORSHAPE,       // number
	VTERM_PROP_MOUSE,             // number
	VTERM_PROP_FOCUSREPORT,       // bool

	VTERM_N_PROPS
};

export def VTERM_PROP_CURSORSHAPE_BLOCK = 1;
export def VTERM_PROP_CURSORSHAPE_UNDERLINE = 2;
export def VTERM_PROP_CURSORSHAPE_BAR_LEFT = 3;

export def VTERM_PROP_MOUSE_NONE = 0;
export def VTERM_PROP_MOUSE_CLICK = 0;
export def VTERM_PROP_MOUSE_DRAG = 0;
export def VTERM_PROP_MOUSE_MOVE = 0;

export type VTermSelectionMask = enum uint {
	VTERM_SELECTION_CLIPBOARD = (1<<0),
	VTERM_SELECTION_PRIMARY   = (1<<1),
	VTERM_SELECTION_SECONDARY = (1<<2),
	VTERM_SELECTION_SELECT    = (1<<3),
	VTERM_SELECTION_CUT0      = (1<<4),
};

export type VTermGlyphInfo = struct {
	chars: const *u32,
	width: int,
	// protected_cell:1; dwl:1, dhl:2
	other: uint,
};

export type VTermLineInfo = struct {
	// doublewidth:1, doubleheight:2, continuation: 1
	details: uint,
};

export type VTermStateFields = struct {
	pos: VTermPos,
	lineinfos: [2]nullable *VTermLineInfo,
};

export type VTermAllocatorFunctions = struct {
	// Must zero out the allocated memory
	malloc: *fn(size, nullable *opaque) nullable *opaque,
	_free: *fn(*opaque, nullable *opaque) void,
};

export type VTermBuilder = struct {
	ver: int,
	rows: int,
	cols: int,
	allocator: nullable *VTermAllocatorFunctions,
	alloc_user: nullable *opaque,
	outbuffer_len: size,
	tmpbuffer_len: size,
};

export @symbol("vterm_build") fn vterm_build(const *VTermBuilder) *VTerm;
export @symbol("vterm_input_write") fn vterm_input_write(*VTerm, const *c::char, size) size;
export @symbol("vterm_set_utf8") fn vterm_set_utf8(*VTerm, int) void;
export @symbol("vterm_get_size") fn vterm_get_size(const *VTerm, *int, *int) void;
export @symbol("vterm_set_size") fn vterm_set_size(*VTerm, int, int) void;

export type VTermScreenCellAttrs = uint; // TODO

export def VTERM_UNDERLINE_OFF = 0;
export def VTERM_UNDERLINE_SINGLE = 1;
export def VTERM_UNDERLINE_DOUBLE = 2;
export def VTERM_UNDERLINE_CURLY = 3;

export def VTERM_BASELINE_NORMAL = 0;
export def VTERM_BASELINE_RAISE = 1;
export def VTERM_BASELINE_LOWER = 2;

export type VTermScreenCell = struct {
	chars: [VTERM_MAX_CHARS_PER_CELL]u32,
	width: u8,
	attrs: VTermScreenCellAttrs,
	fg: VTermColor,
	bg: VTermColor,
};

export type VTermScreenCallbacks = struct {
	damage: nullable *fn(VTermRect, nullable *opaque) int,
	moverect: nullable *fn(VTermRect, VTermRect, nullable *opaque) int,
	movecursor: nullable *fn(VTermPos, VTermPos, int, nullable *opaque) int,
	settermprop: nullable *fn(VTermProp, VTermValue, nullable *opaque) int,
	bell: nullable *fn(nullable *opaque) int,
	resize: nullable *fn(int, int, nullable *opaque) int,
	sb_pushline: nullable *fn(int, const *VTermScreenCell, nullable *opaque) int,
	sb_popline: nullable *fn(int, *VTermScreenCell, nullable *opaque) int,
	sb_clear: nullable *fn(nullable *opaque) int,
};

export @symbol("vterm_obtain_screen") fn vterm_obtain_screen(*VTerm) *VTermScreen;
export @symbol("vterm_screen_set_callbacks") fn vterm_screen_set_callbacks(*VTermScreen, const *VTermScreenCallbacks, nullable *opaque) void;
export @symbol("vterm_screen_get_cell") fn vterm_screen_get_cell(const *VTermScreen, VTermPos, *VTermScreenCell) int;
export @symbol("vterm_screen_convert_color_to_rgb") fn vterm_screen_convert_color_to_rgb(const *VTermScreen, *VTermColor) void;
export @symbol("vterm_screen_reset") fn vterm_screen_reset(*VTermScreen, int) void;
export @symbol("vterm_obtain_state") fn vterm_obtain_state(*VTerm) *VTermState;
export @symbol("vterm_state_reset") fn vterm_state_reset(*VTermState, int) void;
export @symbol("vterm_screen_enable_altscreen") fn vterm_screen_enable_altscreen(*VTermScreen, int) void;

export type VTermOutputCallback = fn(*const c::char, size, nullable *opaque) void;
export @symbol("vterm_output_set_callback") fn vterm_output_set_callback(*VTerm, *VTermOutputCallback, nullable *opaque) void;

export type VTermDamageSize = enum size {
	CELL,
	ROW,
	SCREEN,
	SCROLL,
};

export @symbol("vterm_screen_set_damage_merge") fn vterm_screen_set_damage_merge(*VTermScreen, VTermDamageSize) void;
export @symbol("vterm_screen_flush_damage") fn vterm_screen_flush_damage(*VTermScreen) void;
export @symbol("vterm_keyboard_key") fn vterm_keyboard_key(*VTerm, int, int) void;
