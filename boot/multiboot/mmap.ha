use arch::x86_64;
use boot;
use mb;

let @symbol("_loader_code_start") loader_code_start: [*]u8;
let @symbol("_loader_code_end") loader_code_end: [*]u8;
let @symbol("_loader_data_start") loader_data_start: [*]u8;
let @symbol("_loader_data_end") loader_data_end: [*]u8;
let @symbol("_loader_data_runtime_start") loader_data_runtime_start: [*]u8;
let @symbol("_loader_data_runtime_end") loader_data_runtime_end: [*]u8;

def STATIC_MAREA: size = 256;

// STATIC_MAREA times two is used to ensure we have room to subdivide these
// memory areas
let mmap_static: [STATIC_MAREA * 2]boot::marea = [
	boot::marea { ... }...
];

let mmap: []boot::marea = [];

fn mmap_init(mb: *mb::multiboot) void = {
	assert(mb.flags & mb::INFO_MEM_MAP != 0);

	mmap = mmap_static[..0];

	let nmmap = mb.mmap_length / size(mb::mmap_entry);
	if (nmmap >= STATIC_MAREA) {
		nmmap = STATIC_MAREA;
	};

	const entries = mb.mmap_addr: uintptr: *[*]mb::mmap_entry;
	const entries = entries[..nmmap];
	for (const entry &.. entries) {
		// TODO: This is not strictly speaking required by multiboot
		assert(entry.sz == size(mb::mmap_entry) - size(u32));

		const mtype = switch (entry.typ) {
		case mb::mem_type::AVAILABLE =>
			yield boot::mtype::CONVENTIONAL;
		case mb::mem_type::ACPI_RECLAIMABLE =>
			yield boot::mtype::ACPI_RECLAIM;
		case mb::mem_type::NVS  =>
			yield boot::mtype::ACPI_NVS;
		case => continue;
		};

		// Discard entries with physical addresses outside of our
		// identity map (64 GiB); TODO: support more memory
		if (entry.addr + entry.length >= 0x1000000000) {
			continue;
		};

		static append(mmap, boot::marea {
			phys = entry.addr: uintptr,
			pages = entry.length: size / x86_64::PAGESIZE,
			mtype = mtype,
		});
	};

	mmap_reclassify(
		&loader_code_start: uintptr,
		&loader_code_end: uintptr,
		boot::mtype::LOADER_CODE,
	);
	mmap_reclassify(
		&loader_data_start: uintptr,
		&loader_data_end: uintptr,
		boot::mtype::LOADER_DATA_RECLAIM,
	);
	mmap_reclassify(
		&loader_data_runtime_start: uintptr,
		&loader_data_runtime_end: uintptr,
		boot::mtype::LOADER_DATA_RUNTIME,
	);

	const mods = mb.mods_addr: uintptr: *[*]mb::module;
	const mods = mods[..mb.mods_count];
	for (let i = 0z; i < len(mods); i += 1) {
		const mod = &mods[i];
		mmap_reclassify(
			mod.start: uintptr,
			mod.end: uintptr,
			boot::mtype::LOADER_DATA_RECLAIM,
		);
	};
};

// Reclassifies the given memory range in the memory map.
fn mmap_reclassify(start: uintptr, end: uintptr, kind: boot::mtype) void = {
	// Align on page boundary
	if (start % x86_64::UPAGESIZE != 0) {
		start &= ~0xFFF;
	};
	if (end % x86_64::UPAGESIZE != 0) {
		end &= ~0xFFF;
		end += x86_64::UPAGESIZE;
	};

	const npage = ((end - start) / x86_64::UPAGESIZE): size;
	for (let i = 0z; i < len(mmap); i += 1) {
		const entry = mmap[i];
		let rstart = entry.phys;
		let rend = entry.phys + (entry.pages * x86_64::PAGESIZE): uintptr;
		const rst_orig = rstart, rend_orig = rend;
		if (start >= rend || end <= rstart) {
			// Memory regions do not overlap
			continue;
		};
		if (rstart >= start && rend <= end) {
			// Memory region is entirely located within reclassified
			// memory area
			static delete(mmap[i]);
			continue;
		};

		// Apply changes to rstart and rend as computed by remainder of
		// this algorithm
		defer mmap[i] = boot::marea {
			phys = rstart,
			pages = ((rend - rstart) / x86_64::UPAGESIZE): size,
			mtype = entry.mtype,
		};

		if (rstart >= start) {
			rstart = end;
		};
		if (rend <= end) {
			rend = start;
		};

		if (rst_orig < start && end < rend_orig) {
			// Reclassified region is entirely contained within the
			// original region, which has now been shrunk to the
			// left, and we have to insert a new memory area of the
			// original classification to the right.
			static insert(mmap[i+1], boot::marea {
				phys = end,
				pages = ((rend - end) / x86_64::UPAGESIZE): size,
				mtype = entry.mtype,
			});
		};
	};

	static append(mmap, boot::marea {
		phys = start,
		pages = npage,
		mtype = kind,
	});
};
