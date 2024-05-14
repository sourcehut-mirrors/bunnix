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

let fbdev = chr::fb { ... };

// Performs pre-MMU architecture-specific device initialization.
export fn earlyinit(ctx: *boot::context) void = {
	serial_init(&serialdev, COM1);

	if (ctx.fb.fb_base != 0) {
		const bootfb = &ctx.fb;
		fbdev = chr::fb {
			addr = bootfb.fb_base,
			width = bootfb.width,
			height = bootfb.height,
			stride = bootfb.stride,
			format = bootfb.fmt: chr::pixel_format,
			...
		};
		chr::fb_init(&fbdev);
		vt::fbcons_init(&fbcons, &fbdev);
	} else {
		vga_init(&vgacons);
	};

	rt::abortcons(&chr::cons_write);
};

// Initialize architecture-specific devices.
export fn init() void = {
	cmos_init();
	ps2_init();

	// TODO: Grab ACPI and look for PCIe
	dev::bus_register(&legacy_pci_bus);

	chr::serial_tty_init(&serialdev);

	if (fbcons.vtable != null) {
		vt::fbcons_finish(&fbcons);
		vt::vt_init(&fbdev);
	};
};
