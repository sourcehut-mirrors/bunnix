use boot;
use mb;
use rt;

fn bmain_mb2(mb: *mb::multiboot) never = {
	rt::writestr("bunixboot via multiboot\n");
	abort("TODO");
};

export fn bmain(mb: *mb::multiboot, mb_magic: u32, esp: *opaque) never = {
	switch (mb_magic) {
	case mb::MAGIC =>
		bmain_mb2(mb);
	case mb::MAGIC2 =>
		abort("Multiboot 2 not yet supported");
	case =>
		abort("Unknown multiboot environment");
	};

};
