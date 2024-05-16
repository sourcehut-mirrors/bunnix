use dev;
use dev::chr;
use dev::chr::{key_state};
use errors::{error, errno};
use io;
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
};

// vt console device
export type vtcons = struct {
	io::file,
	dev: nullable *vt,
};

// Allocates a virtual terminal with the given [[chr::fb]]. Will open /dev/kbd
// if available.
export fn vt_init(fb: *chr::fb) *vt = {
	const term = alloc(vt {
		tty_iface = &tty_impl,
		cols = fb.width / FONT_WIDTH,
		rows = fb.height / FONT_HEIGHT,
		cons = vtcons {
			vtable = &cons_impl,
			...
		},
		...
	});
	pixbuf_init_mapped(&term.front, fb);
	pixbuf_init_back(&term.back, fb);
	pixbuf_copy(&term.back, &term.front);

	match (chr::lookup(dev::INPUT_MAJOR, dev::KBD_MINOR)) {
	case let dev: *chr::chardev =>
		const kbd = dev: *chr::kbd;
		chr::kbd_onproc(kbd, &vt_keyev, term);
	case => void;
	};

	chr::tty_init(term, false);

	term.cons.dev = term;
	chr::cons_register(&term.cons);

	return term;
};

const tty_impl = chr::tty_iface {
	write = &vt_write,
	getwinsz = &vt_getwinsz,
};

fn vt_write(tty: *chr::tty, buf: const []u8) (size | error) = {
	let vt = tty: *vt;

	for (let i = 0z; i < len(buf); i += 1) {
		vt_putc(vt, buf[i]: rune);
	};

	vt_present(vt);
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

fn vt_blitchar(vt: *vt, row: uint, col: uint, char: rune) void = {
	const x = col * FONT_WIDTH;
	const y = row * FONT_HEIGHT;
	blitchar(&vt.back, x, y, char);
};

fn vt_putc(vt: *vt, char: rune) void = {
	switch (char) {
	case '\n' =>
		vt.row += 1;
		vt.col = 0;
	case '\r' =>
		vt.col = 0;
	case '\t' =>
		vt.col += 8 - vt.col % 8;
	case '\b' =>
		if (vt.col == 0) {
			return;
		};
		vt.col -= 1;
		vt_blitchar(vt, vt.row, vt.col, ' ');
		vt_damage(vt, vt.row, vt.col);
	case =>
		vt_blitchar(vt, vt.row, vt.col, char);
		vt_damage(vt, vt.row, vt.col);
		vt.col += 1;
	};
	if (vt.col >= vt.cols) {
		vt.col = 0;
		vt.row += 1;
	};
	if (vt.row >= vt.rows) {
		vt.row = vt.rows - 1;
		scroll(&vt.back, FONT_HEIGHT);
		vt_damage(vt, 0, 0, vt.rows, vt.cols);
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
	let damage = &vt.damage;

	if (damage.rows == 0 || damage.cols == 0) {
		return;
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
