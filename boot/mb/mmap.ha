use boot;
use mb;
use types::c;

let @symbol("_loader_code_start") loader_code_start: [*]u8;
let @symbol("_loader_code_end") loader_code_end: [*]u8;
let @symbol("_loader_data_start") loader_data_start: [*]u8;
let @symbol("_loader_data_end") loader_data_end: [*]u8;

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

	mmap_normalize(mb);
};

// Fills in the memory map with more detail, subdividing and retyping areas used
// for the bootloader data.
fn mmap_normalize(mb: *mb::multiboot) void = {
	return; // TODO
};
