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

let serialdev = pcserial {
	cons = chr::serialcons {
		vtable = null: *io::vtable,
		...
	},
	...
};

// Performs pre-MMU architecture-specific device initialization.
export fn earlyinit(ctx: *boot::context) void = {
	serial_init(&serialdev, SERIAL_PORT_A);

	if (ctx.fb.fb_base != 0) {
		vt::fbcons_init(&fbcons, &ctx.fb);
	} else {
		vga_init(&vgacons);
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
