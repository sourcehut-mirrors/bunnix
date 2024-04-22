use arch::{PAGESIZE, UPAGESIZE};
use boot;
use log;
use rt;
use types;

let total_pages: size = 0z;
let pages_used: size = 0z;

const slab_runtime = rt::malloc_iface {
	malloc = &slaballoc,
	free_ = &slabfree,
	realloc = &slabrealloc,
};

export fn init(ctx: *boot::context) void = {
	for (const entry .. ctx.mmap) {
		if (entry.mtype != boot::mtype::CONVENTIONAL) {
			continue;
		};

		assert(entry.pages < types::UINT_MAX);
		const block = new_block(entry.phys, entry.pages: uint);
		total_pages += block.pages;
		pages_used += block.pages_used;
	};

	log::printfln("{} bytes of memory available; {} bytes of overhead",
		total_pages * PAGESIZE, pages_used * PAGESIZE);

	rt::configure_malloc(&slab_runtime);
};
