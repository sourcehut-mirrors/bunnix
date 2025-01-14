// XXX: We should have a better DMA pool abstraction
use errors::{error, errno};
use log;
use mman;

// Number of sectors to keep in the buffer pool.
def NBUFFER: size = 64;

// Size of a disk sector.
def SECTORSZ: size = 512;

export type buffer_pool = struct {
	phys: uintptr,
	virt: *[NBUFFER * SECTORSZ]u8,
	bitmap: u64,
};

export type buffer = struct {
	data: []u8,
	prdt: (uintptr, size),
	mask: u64,
};

export fn buffer_pool_init() *buffer_pool = {
	const nbyte = NBUFFER * SECTORSZ;
	const base = mman::mmap(&mman::kernel, 0, 0, nbyte,
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON | mman::flag::CD | mman::flag::DMA32)!;
	const phys = mman::mmap_phys(&mman::kernel, base: uintptr);
	log::kprintfln(AHCI, "Mapped DMA pool at 0x{:x} : {:x}",
		base, phys);
	return alloc(buffer_pool {
		virt = base: *[NBUFFER * SECTORSZ]u8,
		phys = phys,
		bitmap = 0,
	})!;
};

// Locks a buffer from the pool. May return a buffer smaller than the requested
// size if insufficient buffer space is available. Pass the return value to
// [[releasebuffer]] when done using it.
export fn getbuffer(
	pool: *buffer_pool,
	sectors: size,
) (buffer | error) = {
	// Don't let anyone monopolize more than half of the buffers
	if (sectors > NBUFFER / 2) {
		sectors = NBUFFER / 2;
	};

	// Reduce the client request until we find enough free buffers to
	// fulfill it
	let i = 0u64, mask = 0u64;
	for :outer (sectors > 0; sectors -= 1) {
		mask = (1 << sectors: u64) - 1;
		i = 0u64;
		for (i < (NBUFFER - sectors): u64; i += 1) {
			if (pool.bitmap & (mask << i) == 0) {
				break :outer;
			};
		};
		if (pool.bitmap & (mask << i) == 0) {
			break;
		};
	};
	if (sectors == 0) {
		return errno::BUSY;
	};

	// Make the allocation
	pool.bitmap |= mask << i;

	const start = i * SECTORSZ: u64;
	const end = start + (sectors * SECTORSZ): u64;
	const data = pool.virt[start..end];
	const phys = pool.phys + (i * SECTORSZ: u64): uintptr;
	const sz = sectors * SECTORSZ;
	return buffer {
		data = data,
		prdt = (phys, sz),
		mask = mask << i,
	};
};

// Releases a buffer back to the buffer pool.
export fn releasebuffer(pool: *buffer_pool, buf: *buffer) void = {
	pool.bitmap &= ~buf.mask;
};
