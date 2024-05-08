use arch;
use boot;
use dev;
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

	static let cons = io::teefile {
		vtable = null: *io::vtable,
		primary = null: *io::file,
		secondary = null: *io::file,
		...
	};
	cons = io::tee(consoles[0], consoles[1]);

	log::setcons(&cons);
	rt::abortcons(&log::write);
};

// Initialize architecture-specific devices.
export fn init() void = {
	// TODO: Grab ACPI and look for PCIe
	dev::bus_register(&legacy_pci_bus);

	if (fbcons.vtable != null) {
		vt::fbcons_lateinit(&fbcons);
	};
};
