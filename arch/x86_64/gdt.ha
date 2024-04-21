// See figures 3-8 and 5-1 of the x86 manual
export type seg = enum u64 {
	// Descriptor type (clear = system; set = code or data)
	S = 1 << 44,
	// Present
	P = 1 << 47,
	// 64-bit
	L = 1 << 53,
	// Default operation size (must not be set for 64-bit segments)
	DB = 1 << 54,
	// Granularity
	G = 1 << 55,

	// Accessed
	A = 1 << 40,
	// Readable (for code segments)
	R = 2 << 40,
	// Writable (for data segments)
	W = 2 << 40,
	// Conforming (for code segments)
	C = 4 << 40,
	// Expand-down (for data segments)
	E = 4 << 40,
	// Executable (is code segment)
	X = 8 << 40,

	TSS = 0x9 << 40,
};

// GDT TSS structure
export type tss = struct {
	@offset(0) reserved0: u32,
	@offset(4) rsp: [3]u64,
	@offset(28) reserved1: u64,
	@offset(36) ist: [7]u64,
	@offset(92) reserved2: u64,
	@offset(100) reserved3: u16,
	@offset(102) iomap_base: u16,
};

// Segment descriptor
export type descriptor = struct {
	@offset(6) limit: u16,
	@offset(8) base: u64,
};

// Loads the GDT.
export fn lgdt(base: *opaque, ngdt: size) void = {
	const gdtr = descriptor {
		limit = ngdt: u16 * size(u64): u16 - 1,
		base = base: uintptr: u64,
	};
	_lgdt(&gdtr.limit);
};
