use arch;
use bytes;
use dev;
use dev::chr;
use dev::chr::{key_state};
use errors::{error, errno};
use fmt;
use io;
use lib::vterm;
use rt;
use sched;
use strings;
use time;
use types::c;
use types;

export type vt = struct {
	chr::tty,

	// Console state
	cons: vtcons,
	row: uint,
	col: uint,
	rows: uint,
	cols: uint,

	// Keyboard state
	shift: bool,
	ctrl: bool,

	// Pixel buffers
	front: pixbuf,
	back: pixbuf,

	damage: struct {
		row: uint,
		col: uint,
		rows: uint,
		cols: uint,
	},

	// Terminal state
	vterm: *vterm::VTerm,
	vscreen: *vterm::VTermScreen,

	// Cursor
	cursor: (int, int),
	cursor_shown: bool,
	next_tick: u64,
	last_present: u64,
};

// vt console device
export type vtcons = struct {
	io::file,
	dev: nullable *vt,
};

// Allocates a virtual terminal with the given [[chr::fb]]. Will open /dev/kbd
// if available.
export fn vt_init(fb: *chr::fb) *vt = {
	const rows = fb.height / FONT_HEIGHT;
	const cols = fb.width / FONT_WIDTH;

	const builder = vterm::VTermBuilder {
		rows = rows: int,
		cols = cols: int,
		allocator = &vterm_allocator,
		...
	};
	const vterm = vterm::vterm_build(&builder);
	vterm::vterm_set_utf8(vterm, 1);

	const vscreen = vterm::vterm_obtain_screen(vterm);
	vterm::vterm_screen_reset(vscreen, 1);
	vterm::vterm_screen_enable_altscreen(vscreen, 1);
	vterm::vterm_screen_set_damage_merge(vscreen, vterm::VTermDamageSize::SCROLL);

	const term = alloc(vt {
		tty_iface = &tty_impl,
		rows = rows,
		cols = cols,
		cons = vtcons {
			vtable = &cons_impl,
			...
		},
		cursor = (-1, -1),
		vterm = vterm,
		vscreen = vscreen,
		...
	});
	pixbuf_init_mapped(&term.front, fb);
	pixbuf_init_back(&term.back, fb);

	// Erase the front buffer
	// TODO: Preserve and/or replay early console
	pixbuf_copy(&term.front, &term.front);

	term.vscreen = vscreen;
	term.vterm = vterm;

	vterm::vterm_screen_set_callbacks(vscreen, &vterm_screen_cb, term);

	match (chr::lookup(dev::INPUT_MAJOR, dev::KBD_MINOR)) {
	case let dev: *chr::chardev =>
		const kbd = dev: *chr::kbd;
		chr::kbd_onproc(kbd, &vt_keyev, term);
	case => void;
	};

	chr::tty_init(term, false);

	term.cons.dev = term;
	chr::cons_register(&term.cons);

	static let link = sched::tick_link { ... };
	sched::ontick(&link, &vt_tick, term);

	return term;
};

const vterm_allocator = vterm::VTermAllocatorFunctions {
	malloc = &vterm_malloc,
	_free = &vterm_free,
};

fn vterm_malloc(n: size, user: nullable *opaque) nullable *opaque = {
	return rt::malloc(n);
};

fn vterm_free(p: *opaque, user: nullable *opaque) void = {
	return rt::free_(p);
};

const vterm_screen_cb = vterm::VTermScreenCallbacks {
	damage = &vterm_damage,
	moverect = &vterm_moverect,
	movecursor = &vterm_movecursor,
	...
};

fn vterm_damage(r: vterm::VTermRect, user: nullable *opaque) int = {
	const vt = user: *vt;
	const rows = r.end_row - r.start_row;
	const cols = r.end_col - r.start_col;
	vt_damage(vt,
		r.start_row: uint,
		r.start_col: uint,
		rows: uint,
		cols: uint);
	return 1;
};

fn vterm_moverect(
	dest: vterm::VTermRect,
	src: vterm::VTermRect,
	user: nullable *opaque,
) int = {
	const vt = user: *vt;
	const src_rect = &rect {
		x = src.start_col: uint * FONT_WIDTH,
		y = src.start_row: uint * FONT_HEIGHT,
		w = (src.end_col - src.start_col): uint * FONT_WIDTH,
		h = (src.end_row - src.start_row): uint * FONT_HEIGHT,
	};
	const dest_rect = &rect {
		x = dest.start_col: uint * FONT_WIDTH,
		y = dest.start_row: uint * FONT_HEIGHT,
		w = (dest.end_col - dest.start_col): uint * FONT_WIDTH,
		h = (dest.end_row - dest.start_row): uint * FONT_HEIGHT,
	};
	pixbuf_copyrect(&vt.back, &vt.back, src_rect, dest_rect);
	vterm_damage(src, vt);
	vterm_damage(dest, vt);
	return 1;
};

fn vterm_movecursor(
	pos: vterm::VTermPos,
	old: vterm::VTermPos,
	visible: int,
	user: nullable *opaque,
) int = {
	const vt = user: *vt;
	// TODO
	return 1;
};

const tty_impl = chr::tty_iface {
	write = &vt_write,
	getwinsz = &vt_getwinsz,
};

fn vt_write(tty: *chr::tty, buf: const []u8) (size | error) = {
	const vt = tty: *vt;
	const vterm = vt.vterm;

	for (let i = 0z; i < len(buf); i += 1) {
		vterm::vterm_input_write(vterm, &buf[i]: *c::char, 1);
		if (buf[i] == '\n') {
			vterm::vterm_input_write(vterm, &('\r': u8): *c::char, 1);
		};
	};

	if (vt.last_present == 0) {
		vt_present(vt);
	};

	return len(buf);
};

fn vt_getwinsz(tty: *chr::tty) (uint, uint) = {
	const term = tty: *vt;
	return (term.rows, term.cols);
};

const cons_impl = io::vtable {
	write = &vt_cons_write,
	...
};

fn vt_cons_write(cons: *io::file, buf: const []u8) (size | error) = {
	const cons = cons: *vtcons;
	return vt_write(cons.dev as *vt, buf);
};

fn vt_keyev(code: u32, state: key_state, user: nullable *opaque) void = {
	let term = user: *vt;

	switch (code) {
	case K_LFSH, K_RTSH =>
		term.shift = state == key_state::PRESSED;
	case K_LCTL =>
		term.ctrl = state == key_state::PRESSED;
	case => yield;
	};

	const keycode = code: size - 8;
	if (state != key_state::PRESSED || keycode >= len(keysyms)) {
		return;
	};

	const layer = if (term.shift) 1 else 0;
	const sym = keysyms[keycode][layer];
	if (sym == '\0') {
		return;
	};
	if (sym == 'd' && term.ctrl && !term.shift) {
		chr::tty_putc(term, '\x04'); // EOF
		return;
	};

	chr::tty_putc(term, sym: u8);
};

fn vt_tick(tick: u64, user: nullable *opaque) void = {
	let vt = user: *vt;
	const rate = arch::getrate();

	// Present no faster than 24 Hz
	const ellapsed = tick - vt.last_present;
	const deadline = rate / 24;
	if (ellapsed > deadline) {
		vt_present(vt);
	};
};

fn vt_blitchar(
	vt: *vt,
	row: uint,
	col: uint,
	char: rune,
	color: u32 = 0xFFFFFFFF,
	op: blit_op = blit_op::OVER,
) void = {
	const x = col * FONT_WIDTH;
	const y = row * FONT_HEIGHT;
	blitchar(&vt.back, x, y, char, color, op);
};

fn vt_blitcursor(vt: *vt) void = {
	def COLOR: u32 = 0xFFFFFFFF;

	const (row, col) = vt.cursor;
	if (row != -1 && row != -1) {
		const row = row: uint;
		const col = col: uint;
		vt_blitchar(vt, row, col, '_', COLOR, blit_op::XOR);
		vt_damage(vt, row, col);
	};
};

fn vt_damage(
	vt: *vt,
	row: uint,
	col: uint,
	rows: uint = 1,
	cols: uint = 1,
) void = {
	let d = &vt.damage;
	if (d.row == types::UINT_MAX || d.col == types::UINT_MAX) {
		d.row = row;
		d.col = col;
		d.rows = rows;
		d.cols = cols;
		return;
	};

	const r1 = if (d.row < row) d.row else row;
	const r2 = if (d.row + d.rows < row + rows) row + rows else d.row + d.rows;
	const c1 = if (d.col < col) d.col else col;
	const c2 = if (d.col + d.cols < col + cols) col + cols else d.col + d.cols;

	d.row = r1;
	d.col = c1;
	d.rows = r2 - r1;
	d.cols = c2 - c1;
};

fn vt_present(vt: *vt) void = {
	vt.last_present = arch::gettime();

	const vscreen = vt.vscreen;
	vterm::vterm_screen_flush_damage(vscreen);

	let damage = &vt.damage;
	if (damage.rows == 0 || damage.cols == 0) {
		return;
	};

	const fb = vt.front.fb: *chr::fb;
	for (let row = damage.row; row < damage.row + damage.rows; row += 1)
	for (let col = damage.col; col < damage.col + damage.cols; col += 1) {
		let cell = vterm::VTermScreenCell { ... };
		vterm::vterm_screen_get_cell(vscreen, vterm::VTermPos {
			row = row: int,
			col = col: int,
		}, &cell);

		const x = col: uint * FONT_WIDTH;
		const y = row: uint * FONT_HEIGHT;
		blitrect(&vt.back, x, y, FONT_WIDTH, FONT_HEIGHT);

		if (cell.chars[0] == 0) {
			continue;
		};

		vterm::vterm_screen_convert_color_to_rgb(vscreen, &cell.fg);
		const fg =
			0xFF000000 |
			cell.fg.rgb.red: u32	<< 16 |
			cell.fg.rgb.green: u32	<< 8 |
			cell.fg.rgb.blue: u32	<< 0;

		vt_blitchar(vt, row, col, cell.chars[0]: rune, fg);
	};

	pixbuf_copyrect(&vt.front, &vt.back, &rect {
		x = damage.col * FONT_WIDTH,
		y = damage.row * FONT_HEIGHT,
		w = damage.cols * FONT_WIDTH,
		h = damage.rows * FONT_HEIGHT,
	});

	damage.row = types::UINT_MAX;
	damage.col = types::UINT_MAX;
	damage.rows = 0;
	damage.cols = 0;
};
