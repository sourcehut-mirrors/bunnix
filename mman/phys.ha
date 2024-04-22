// Physical memory manager (simple bitmap allocator)
use arch;
use arch::{PAGESIZE, UPAGESIZE};
use errors::{error, errno};
use log;

// Head of linked list of memory manager structures.
let mhead: nullable *block = null;

// Memory flags.
export type mflag = enum uint {
	NONE = 0,
	// 32-bit memory for DMA use
	LOWMEM = 1 << 0,
};

export type block = struct {
	base: uintptr,
	pages: uint,
	pages_used: uint,
	min_free_page: uint,
	flags: mflag,
	bitmap: []u8,
	refcount: []u8,
	next: nullable *block,
};

export fn newblock(
	phys: uintptr,
	pages: uint,
	flags: mflag = mflag::NONE,
) *block = {
	log::printfln("Initializing block at 0x{:x} of {} pages", phys, pages);

	let data: *[*]u8 = arch::phys_tokernel(phys): *[*]u8;
	let data = data[..pages * PAGESIZE];
	if (phys < 2 << 32) {
		flags |= mflag::LOWMEM;
	};

	// Length of bitmap in bytes
	const bitmaplen =
		if (pages % 8 == 0) pages / 8
		else pages / 8 + 1;
	// Length of refcounts in bytes
	const refcounts = pages;

	// Total overhead, in bytes
	const overhead = refcounts + bitmaplen + size(block);

	// Total overhead in pages
	const overpages =
		if (overhead % PAGESIZE == 0) overhead / PAGESIZE
		else overhead / PAGESIZE + 1;
	assert(overpages <= pages);
	const overpages = overpages: uint;

	let ix = 0z;
	let blk = &data[0]: *block;
	ix += size(block);

	let bitmap = data[ix..ix+bitmaplen];
	ix += bitmaplen;

	let refcount = data[ix..ix+refcounts];

	// Mark overhead as in use
	for (let i = 0z; i < overpages; i += 1) {
		bitmap[i / 8] |= (1 << (i % 8)): u8;
	};

	*blk = block {
		base = phys,
		pages = pages,
		pages_used = overpages,
		min_free_page = 0,
		flags = flags,
		bitmap = bitmap,
		refcount = refcount,
		next = mhead,
	};
	mhead = blk;

	return blk;
};

// Allocates enough continuous pages of physical memory to satisfy a request of
// "length" bytes, returning the first physical address of the allocation.
export fn physalloc(
	length: size,
	flags: mflag = mflag::NONE,
) (uintptr | error) = {
	let cur = mhead;

	let npage = (length / PAGESIZE): uint;
	if (length % PAGESIZE != 0) {
		npage += 1;
	};

	// TODO: Prioritize high memory if the user did not request low memory
	// explicitly (to save low memory for such requests)
	for (cur != null; cur = (cur: *block).next) {
		const cur = cur as *block;
		if (flags != mflag::NONE && cur.flags != flags) {
			continue;
		};
		if (cur.pages - cur.pages_used < npage) {
			continue; // Don't bother
		};

		let i = cur.min_free_page;
		for (i < cur.pages; i += 1) {
			let avail = true;
			for (let j = 0z; j < npage; j += 1) {
				const ix = (i + j) / 8;
				const shift = ((i + j) % 8): u8;
				avail &&= (cur.bitmap[ix] >> shift) & 1 == 0;
			};

			if (avail) {
				break;
			};
		};
		if (i >= cur.pages) {
			continue;
		};

		const base = cur.base + i * UPAGESIZE;
		for (let j = 0z; j < npage; j += 1) {
			const ix = (i + j) / 8;
			const shift = ((i + j) % 8): u8;
			cur.bitmap[ix] |= 1 << shift;
			assert(cur.refcount[i + j] == 0);
			cur.refcount[i + j] = 1;
		};

		cur.pages_used += npage;
		cur.min_free_page = i + npage;
		return base;
	};

	return errno::NOMEM;
};

// Increments the reference count of the given range of pages.
export fn ref(addr: uintptr, length: size) (void | error) = {
	abort(); // TODO
};

// Decrements the reference count of the given range of pages, freeing them if
// necessary.
export fn unref(addr: uintptr, length: size) void = {
	abort(); // TODO
};
