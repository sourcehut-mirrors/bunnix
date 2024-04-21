use rt;
use mb;

fn bmain_mb2(mb: *mb::multiboot) never = {
	rt::writestr("bunixboot via multiboot\n");
	abort("TODO");
};

export fn bmain(mb: *mb::multiboot, mb_magic: u32, esp: *opaque) never = {
	switch (mb_magic) {
	case mb::MB_MAGIC =>
		bmain_mb2(mb);
	case mb::MB2_MAGIC =>
		abort("Multiboot 2 not yet supported");
	case =>
		abort("Unknown multiboot environment");
	};

};
