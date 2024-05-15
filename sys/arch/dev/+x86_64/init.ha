use arch;
use boot;
use dev;
use dev::chr;
use io;
use log;
use rt;
use vt;

let fbcons = vt::fb_console {
	vtable = null: *io::vtable,
	...
};

let vgacons = vga_console {
	vtable = null: *io::vtable,
	...
};

let serialcons = serial_console {
	vtable = null: *io::vtable,
	...
};

def MAX_EARLYCONS: uint = 2;
let consolebuf: [MAX_EARLYCONS]*io::file = [null: *io::file...];
let consoles: []*io::file = [];

// Performs pre-MMU architecture-specific device initialization.
export fn earlyinit(ctx: *boot::context) void = {
	// TODO: This should be refactored a bit
	consoles = consolebuf[..0];

	serial_init(&serialcons, SERIAL_PORT_A);
	static append(consoles, &serialcons);

	if (ctx.fb.fb_base != 0) {
		vt::fbcons_init(&fbcons, &ctx.fb);
		static append(consoles, &fbcons);
	} else {
		vga_init(&vgacons);
		static append(consoles, &vgacons);
	};

	rt::abortcons(&chr::cons_write);
};

// Initialize architecture-specific devices.
export fn init() void = {
	if (fbcons.vtable != null) {
		vt::fbcons_lateinit(&fbcons);
	};

	// TODO: Grab ACPI and look for PCIe
	dev::bus_register(&legacy_pci_bus);

	ps2_init();

	if (fbcons.vtable != null) {
		vt::tty_init(&fbcons);
	};

	cmos_init();
};
