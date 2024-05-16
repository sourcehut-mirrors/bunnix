use dev;
use dev::chr;
use dev::chr::{key_state};
use errors::{error, errno};

export type vt = struct {
	chr::tty,

	row: uint,
	col: uint,
	rows: uint,
	cols: uint,

	// Keyboard state
	kbd: *chr::kbd,
	shift: bool,
	ctrl: bool,

	// Pixel buffers
	front: pixbuf,
	back: pixbuf,
};

// Allocates a virtual terminal with the given [[chr::fb]]. Will open /dev/kbd
// if available.
export fn vt_init(fb: *chr::fb) *vt = {
	const kbd = chr::lookup(dev::INPUT_MAJOR, dev::KBD_MINOR)!: *chr::kbd;

	// TODO:
	// - s/WIDTH/FONT_WIDTH/g
	// - Add vt to /dev/cons
	const term = alloc(vt {
		tty_iface = &tty_impl,
		kbd = kbd,
		cols = fb.width / (WIDTH + 1),
		rows = fb.height / HEIGHT,
		...
	});
	pixbuf_init_mapped(&term.front, fb);
	pixbuf_init_back(&term.back, fb);
	pixbuf_copy(&term.back, &term.front);

	chr::kbd_onproc(kbd, &vt_keyev, term);
	chr::tty_init(term, false);

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
		const x = vt.col * (WIDTH + 1);
		const y = vt.row * HEIGHT;
		blitrect(&vt.back, x, y, WIDTH + 1, HEIGHT);
	case =>
		const x = vt.col * (WIDTH + 1);
		const y = vt.row * HEIGHT;
		blitrect(&vt.back, x, y, WIDTH + 1, HEIGHT);
		blitchar(&vt.back, x, y, char);
		vt.col += 1;
	};
	if (vt.col >= vt.cols) {
		vt.col = 0;
		vt.row += 1;
	};
	if (vt.row >= vt.rows) {
		vt.row = vt.rows - 1;
		scroll(&vt.back, HEIGHT);
	};
};

fn vt_present(vt: *vt) void = {
	pixbuf_copy(&vt.front, &vt.back);
};
