use arch::{PAGESIZE, UPAGESIZE};
use boot;
use log;
use rt;
use types;

const MMAN: str = "mman";

// Flags for [[mmap]] operations.
export type prot = enum uint {
	NONE	= 0,
	READ	= 1 << 0,
	WRITE	= 1 << 1,
	EXEC	= 1 << 2,
};

// Flags for [[mmap]] operations.
export type flag = enum uint {
	NONE = 0,
	ANON = 1 << 0,

	// == Kernel flags

	// Mapping visible to userspace
	USER	= 1 << 24,
	// Disable cache
	CD	= 1 << 25,
	// Write-through
	WT	= 1 << 26,
	// When combined with ANON, causes the physical pages to be allocated
	// from low memory.
	DMA32	= 1 << 27,
};

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

	log::kprintfln(MMAN,
		"{} bytes of memory available; {} bytes of overhead",
		total_pages * PAGESIZE, pages_used * PAGESIZE);

	rt::configure_malloc(&slab_runtime);
};
