use arch::{PAGESIZE, UPAGESIZE};
use boot;
use log;
use types;

let total_pages: size = 0z;
let pages_used: size = 0z;

export fn init(ctx: *boot::context) void = {
	log::println("init memory manager");
	for (const entry .. ctx.mmap) {
		if (entry.mtype != boot::mtype::CONVENTIONAL) {
			continue;
		};

		assert(entry.pages < types::UINT_MAX);
		const block = newblock(entry.phys, entry.pages: uint);
		total_pages += block.pages;
		pages_used += block.pages_used;
	};

	log::printfln("{} bytes of memory available; {} bytes of overhead",
		total_pages * PAGESIZE, pages_used * PAGESIZE);
};
