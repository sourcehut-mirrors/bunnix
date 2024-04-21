use boot;
use format::elf;
use mb;
use rt;

type kentry = fn(ctx: *boot::bootctx) never;

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

fn bmain_mb2(mb: *mb::multiboot) never = {
	rt::writestr("bunnixboot: booting via multiboot... ");
	assert(mb.mods_count >= 1, "Nothing to boot? Did you provide a multiboot module?");

	mmap_init(mb);
	mmu_init();

	const bctx = bootctx_init(mb);

	const mods = mb.mods_addr: uintptr: *[*]mb::module;
	const mods = mods[..mb.mods_count];
	const image = mods[0].start: uintptr: *elf::header64;
	const kenter = load(image);

	// Note: the loader can overwrite the multiboot context, which can no
	// longer be used beyond this point.

	rt::writestr("ok\n");
	kenter(bctx);
};
