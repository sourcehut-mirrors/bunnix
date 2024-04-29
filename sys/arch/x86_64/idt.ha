export type idt_entry = struct {
	@offset(0) base_low: u16,
	@offset(2) sel: u16,
	@offset(4) flags: u16,
	@offset(6) base_mid: u16,
	@offset(8) base_high: u32,
	@offset(12) reserved: u32,
};

export def NINT: size = 256;

// An interrupt descriptor table.
export type idt = [NINT]idt_entry;

// Interrupt request assignments on x86_64.
export type irq = enum u8 {
	DE = 0,
	DB = 1,
	NMI = 2,
	BP = 3,
	OF = 4,
	BR = 5,
	UD = 6,
	NM = 7,
	DF = 8,
	RESERVED_COPROCESSOR_SEGMENT_OVERRUN = 9,
	TS = 10,
	NP = 11,
	SS = 12,
	GP = 13,
	PF = 14,
	RESERVED0 = 15,
	MF = 16,
	AC = 17,
	MC = 18,
	XM = 19,
	VE = 20,
	CP = 21,
	// 22-31 also reserved
	// 32-255 user-defined
};

// Configures the specified gate in the IDT.
export fn idt_set_gate(
	idt: *idt,
	irq: u8,
	handler: *opaque,
	sel: u16,
	flags: u16,
) void = {
	const base = handler: uintptr;
	idt[irq].base_low = base: u16;
	idt[irq].base_mid = (base >> 16): u16;
	idt[irq].base_high = (base >> 32): u32;
	idt[irq].sel = sel << 3;
	idt[irq].flags = flags;
};

// Loads an IDT.
export fn lidt(base: *idt) void = {
	const idtr = descriptor {
		limit = NINT: u16 * size(idt_entry): u16 - 1,
		base = base: uintptr: u64,
	};
	_lidt(&idtr.limit);
};
