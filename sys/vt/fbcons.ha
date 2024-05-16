use arch;
use dev::chr;
use errors::{error, errno};
use io;
use rt;

// Basic framebuffer console suitable for pre-MMU use.
export type fb_console = struct {
	io::file,
	pixbuf: pixbuf,
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
		cols = fb.width / (WIDTH + 1),
		rows = fb.height / HEIGHT,
		...
	};
	pixbuf_init_ident(&cons.pixbuf, fb);
	pixbuf_clear(&cons.pixbuf);

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
		blitrect(&cons.pixbuf, x, y, WIDTH + 1, HEIGHT);
	case =>
		const x = cons.col * (WIDTH + 1);
		const y = cons.row * HEIGHT;
		blitrect(&cons.pixbuf, x, y, WIDTH + 1, HEIGHT);
		blitchar(&cons.pixbuf, x, y, char);
		cons.col += 1;
	};
	if (cons.col >= cons.cols) {
		cons.col = 0;
		cons.row += 1;
	};
	if (cons.row >= cons.rows) {
		cons.row = cons.rows - 1;
		scroll(&cons.pixbuf, HEIGHT);
	};
};
