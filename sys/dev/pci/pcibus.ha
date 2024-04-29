use dev;

// A PCI bus device
export type pcibus = struct {
	dev::bus,
	impl: *pcibus_iface,
};

// Function to read a long from PCI configuration space.
export type fn_pci_readl = fn(bus: *pcibus, device: u32, offs: u8) u32;

// Function to read a word from PCI configuration space.
export type fn_pci_readw = fn(bus: *pcibus, device: u32, offs: u8) u16;

// Function to read a byte from PCI configuration space.
export type fn_pci_readb = fn(bus: *pcibus, device: u32, offs: u8) u8;

// Function to write a long to PCI configuration space.
export type fn_pci_writel = fn(bus: *pcibus, device: u32, offs: u8, val: u32) void;

// Function to write a word to PCI configuration space.
export type fn_pci_writew = fn(bus: *pcibus, device: u32, offs: u8, val: u16) void;

// Function to write a byte to PCI configuration space.
export type fn_pci_writeb = fn(bus: *pcibus, device: u32, offs: u8, val: u8) void;

// PCI interface
export type pcibus_iface = struct {
	readl: *fn_pci_readl,
	readw: *fn_pci_readw,
	readb: *fn_pci_readb,
	writel: *fn_pci_writel,
	writew: *fn_pci_writew,
	writeb: *fn_pci_writeb,
};

// Read a long from PCI configuration space.
export fn readl(bus: *pcibus, device: u32, offs: u8) u32 = {
	return bus.impl.readl(bus, device, offs);
};

// Read a word from PCI configuration space.
export fn readw(bus: *pcibus, device: u32, offs: u8) u16 = {
	return bus.impl.readw(bus, device, offs);
};

// Read a byte from PCI configuration space.
export fn readb(bus: *pcibus, device: u32, offs: u8) u8 = {
	return bus.impl.readb(bus, device, offs);
};

// Write a long to PCI configuration space.
export fn writel(bus: *pcibus, device: u32, offs: u8, val: u32) void = {
	bus.impl.writel(bus, device, offs, val);
};

// Write a word to PCI configuration space.
export fn writew(bus: *pcibus, device: u32, offs: u8, val: u16) void = {
	bus.impl.writew(bus, device, offs, val);
};

// Write a byte to PCI configuration space.
export fn writeb(bus: *pcibus, device: u32, offs: u8, val: u8) void = {
	bus.impl.writeb(bus, device, offs, val);
};
