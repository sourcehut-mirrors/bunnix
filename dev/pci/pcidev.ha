// A PCI bus device
export type pcidev = struct {
	impl: *pcidev_iface,
};

// Function to read a long from PCI configuration space.
export type fn_pci_readl = fn(dev: *pcidev, device: u32, offs: u8) u32;

// Function to read a word from PCI configuration space.
export type fn_pci_readw = fn(dev: *pcidev, device: u32, offs: u8) u16;

// Function to read a byte from PCI configuration space.
export type fn_pci_readb = fn(dev: *pcidev, device: u32, offs: u8) u8;

// Function to write a long to PCI configuration space.
export type fn_pci_writel = fn(dev: *pcidev, device: u32, offs: u8, val: u32) void;

// Function to write a word to PCI configuration space.
export type fn_pci_writew = fn(dev: *pcidev, device: u32, offs: u8, val: u16) void;

// Function to write a byte to PCI configuration space.
export type fn_pci_writeb = fn(dev: *pcidev, device: u32, offs: u8, val: u8) void;

// PCI interface
export type pcidev_iface = struct {
	readl: *fn_pci_readl,
	readw: *fn_pci_readw,
	readb: *fn_pci_readb,
	writel: *fn_pci_writel,
	writew: *fn_pci_writew,
	writeb: *fn_pci_writeb,
};

// Read a long from PCI configuration space.
export fn readl(dev: *pcidev, device: u32, offs: u8) u32 = {
	return dev.impl.readl(dev, device, offs);
};

// Read a word from PCI configuration space.
export fn readw(dev: *pcidev, device: u32, offs: u8) u16 = {
	return dev.impl.readw(dev, device, offs);
};

// Read a byte from PCI configuration space.
export fn readb(dev: *pcidev, device: u32, offs: u8) u8 = {
	return dev.impl.readb(dev, device, offs);
};

// Write a long to PCI configuration space.
export fn writel(dev: *pcidev, device: u32, offs: u8, val: u32) void = {
	dev.impl.writel(dev, device, offs, val);
};

// Write a word to PCI configuration space.
export fn writew(dev: *pcidev, device: u32, offs: u8, val: u16) void = {
	dev.impl.writew(dev, device, offs, val);
};

// Write a byte to PCI configuration space.
export fn writeb(dev: *pcidev, device: u32, offs: u8, val: u8) void = {
	dev.impl.writeb(dev, device, offs, val);
};
