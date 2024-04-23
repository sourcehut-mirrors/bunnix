// PCI Base Address Register
export type bar = enum uint {
	BAR0,
	BAR1,
	BAR2,
	BAR3,
	BAR4,
	BAR5,
};

// Returns the address of a BAR register. The return value includes the PCI
// flags; the caller should interpret them or mask them out.
export fn read_bar_addr(bus: *pcibus, device: u32, bar: bar) uintptr = {
	const bar = bar: u8;
	let val: u64 = readl(bus, device, PCI_BAR0 + bar * 4);
	if (val & 1 == 1) {
		// I/O space
		return val: uintptr;
	};
	switch ((val & 0b110) >> 1) {
	case 0, 1 =>
		return val: uintptr;
	case 2 =>
		const msw = readl(bus, device, PCI_BAR0 + (bar + 1) * 4);
		return (val | msw << 32): uintptr;
	case => abort();
	};
};

// Returns the length of the given BAR register's memory area.
export fn probe_bar_size(bus: *pcibus, device: u32, bar: bar) size = {
	const bar = bar: u8;
	const orig = readl(bus, device, PCI_BAR0 + bar * 4);
	defer writel(bus, device, PCI_BAR0 + bar * 4, orig);
	writel(bus, device, PCI_BAR0 + bar * 4, ~0u32);
	let val = readl(bus, device, PCI_BAR0 + bar * 4);

	if (orig & 1 == 1) {
		val &= 0xFFFFFFFC;
		if (orig & 0xFFFF0000 == 0) {
			val &= 0x0000FFFF;
		};
	} else {
		// XXX: Not exactly right for 64-bit BARs
		val &= 0xFFFFFFF0;
	};

	return val & ~(val - 1);
};
