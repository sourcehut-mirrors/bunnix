use mb;

@symbol("bmain") fn bmain(mb: *mb::multiboot, mb_magic: u32, esp: *opaque) never;

export fn start(mb: *mb::multiboot, mb_magic: u32, esp: *opaque) never = {
	do_init();
	bmain(mb, mb_magic, esp);
};
