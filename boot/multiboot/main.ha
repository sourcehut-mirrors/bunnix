use boot;
use format::elf;
use mb;
use rt;

type kentry = fn(ctx: *boot::context) never;

export fn bmain(mb: *mb::multiboot, mb_magic: u32, esp: *opaque) never = {
	switch (mb_magic) {
	case mb::MAGIC =>
		bmain_mb1(mb);
	case mb::MAGIC2 =>
		abort("Multiboot 2 not yet supported");
	case =>
		abort("Unknown multiboot environment");
	};
};

fn bmain_mb1(mb: *mb::multiboot) never = {
	rt::writestr("bunnixboot: booting via multiboot 0.X... ");
	assert(mb.mods_count >= 1, "Nothing to boot? Did you provide a multiboot module?");

	mmap_init(mb);
	mmu_init();

	let bctx = bootctx_init(mb);
	if (mb.flags & mb::INFO_VIDEO_INFO != 0) {
		const minfo = mb.vbe_mode_info: uintptr: *mb::vbe_mode_info;
		bctx.fb.fb_base = minfo.framebuffer: uintptr;
		bctx.fb.fb_size = minfo.pitch: size * minfo.height: size;
		bctx.fb.fmt = boot::pixel_format::RGBX8; // TODO
		bctx.fb.width = minfo.width;
		bctx.fb.height = minfo.height;
		bctx.fb.stride = minfo.pitch;
	};

	const mods = mb.mods_addr: uintptr: *[*]mb::module;
	const mods = mods[..mb.mods_count];
	const image = mods[0].start: uintptr: *elf::header64;
	const kenter = load(image);

	// Note: the loader can overwrite the multiboot context, which can no
	// longer be used beyond this point.

	// The loader can modify the memory map (to make room for the kernel)
	bctx.mmap = mmap;

	rt::writestr("ok\n");
	kenter(bctx);
};
