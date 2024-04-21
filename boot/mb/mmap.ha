use boot;
use mb;
use types::c;

let @symbol("_loader_code_start") loader_code_start: [*]u8;
let @symbol("_loader_code_end") loader_code_end: [*]u8;
let @symbol("_loader_data_start") loader_data_start: [*]u8;
let @symbol("_loader_data_end") loader_data_end: [*]u8;
let @symbol("_loader_data_runtime_start") loader_data_runtime_start: [*]u8;
let @symbol("_loader_data_runtime_end") loader_data_runtime_end: [*]u8;

def PAGESIZE: size = 4096;
def UPAGESIZE: uintptr = 4096: uintptr;

def STATIC_MAREA: size = 256;

// STATIC_MAREA times two is used to ensure we have room to subdivide these
// memory areas
let mmap_static: [STATIC_MAREA * 2]boot::marea = [
	boot::marea { ... }...
];

let mmap: []boot::marea = [];

fn mmap_init(mb: *mb::multiboot) void = {
	mmap = mmap_static[..0];

	let nmmap = mb.mmap_length / size(mb::mmap_entry);
	if (nmmap >= STATIC_MAREA) {
		nmmap = STATIC_MAREA;
	};

	const entries = mb.mmap_addr: uintptr: *[*]mb::mmap_entry;
	const entries = entries[..nmmap];
	for (const entry &.. entries) {
		const mtype = switch (entry.typ) {
		case mb::mem_type::AVAILABLE =>
			yield boot::mtype::CONVENTIONAL;
		case mb::mem_type::ACPI_RECLAIMABLE  =>
			yield boot::mtype::ACPI_RECLAIM;
		case mb::mem_type::NVS  =>
			yield boot::mtype::ACPI_NVS;
		case => continue;
		};

		static append(mmap, boot::marea {
			phys = entry.addr: uintptr,
			pages = entry.length,
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

	// Skip the first module (i.e. the kernel)
	const mods = mb.mods_addr: uintptr: *[*]mb::module;
	const mods = mods[..mb.mods_count];
	for (let i = 1z; i < len(mods); i += 1) {
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
	if (start % UPAGESIZE != 0) {
		start &= ~(UPAGESIZE - 1);
	};
	if (end % UPAGESIZE != 0) {
		end &= ~(UPAGESIZE - 1);
		end += UPAGESIZE;
	};

	const npage = ((end - start) / UPAGESIZE): size;
	for (let i = 0z; i < len(mmap); i += 1) {
		const entry = mmap[i];
		const estart = entry.phys;
		const eend = entry.phys + entry.pages: uintptr * UPAGESIZE;
		if (estart <= start && eend > end) {
			// [...####...]
			static delete(mmap[i]);
			static insert(mmap[i], boot::marea {
				phys = entry.phys,
				pages = ((end - estart) / UPAGESIZE): size,
				mtype = entry.mtype,
			});
			static insert(mmap[i+1], boot::marea {
				phys = start,
				pages = npage,
				mtype = kind,
			});
			static insert(mmap[i+2], boot::marea {
				phys = end,
				pages = ((eend - end) / UPAGESIZE): size,
				mtype = entry.mtype,
			});
			i += 2;
		} else if (estart <= start && eend > start) {
			// [...##]##...
			abort(); // TODO
		} else if (estart <= end && eend > end) {
			// ...##[##...]
			abort(); // TODO
		};
	};
};
