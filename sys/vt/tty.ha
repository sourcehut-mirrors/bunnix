use dev;
use dev::chr;
use dev::chr::{key_state};
use errors::{error, errno};

export type fb_tty = struct {
	chr::tty,
	fb: *fb_console,
	kbd: *chr::kbd,
	shift: bool,
};

// Allocates a virtual terminal with the given [[fb_console]]. Will open
// /dev/kbd if available.
export fn tty_init(fb: *fb_console) void = {
	const kbd = chr::lookup(dev::INPUT_MAJOR, dev::KBD_MINOR)!: *chr::kbd;

	const tty = alloc(fb_tty {
		// Filled in by chr::tty_init
		iface = null: *chr::chardev_iface,
		tty_iface = &tty_impl,
		fb = fb,
		kbd = kbd,
		...
	});
	chr::kbd_onproc(kbd, &tty_keyev, tty);
	chr::tty_init(tty, false);
};

const tty_impl = chr::tty_iface {
	write = &tty_write,
	getwinsz = &tty_getwinsz,
};

fn tty_write(tty: *chr::tty, buf: const []u8) (size | error) = {
	const tty = tty: *fb_tty;
	return fbcons_write(tty.fb, buf);
};

fn tty_getwinsz(tty: *chr::tty) (uint, uint) = {
	const tty = tty: *fb_tty;
	return (tty.fb.rows, tty.fb.cols);
};

fn tty_keyev(code: u32, state: key_state, user: nullable *opaque) void = {
	let tty = user: *fb_tty;

	switch (code) {
	case K_LFSH, K_RTSH =>
		tty.shift = state == key_state::PRESSED;
	case K_LCTL =>
		// TODO: ^D should send EOF
		void;
	case => yield;
	};

	const keycode = code: size - 8;
	if (state != key_state::PRESSED || keycode >= len(keysyms)) {
		return;
	};

	const layer = if (tty.shift) 1 else 0;
	const sym = keysyms[keycode][layer];
	if (sym == '\0') {
		return;
	};
	chr::tty_putc(tty, sym: u8);
};
