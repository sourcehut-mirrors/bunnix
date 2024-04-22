// A PCI bus device
export type pcidev = struct {
	impl: *pcidev_iface,
};

// PCI Base Address Register
export type bar = enum uint {
	BAR0,
	BAR1,
	BAR2,
	BAR3,
	BAR4,
	BAR5,
};

// Function to read a long from PCI configuration space.
export type fn_pci_readl = fn(dev: *pcidev, device: u32, offs: u8) u64;

// Function to read a word from PCI configuration space.
export type fn_pci_readw = fn(dev: *pcidev, device: u32, offs: u8) u32;

// Function to read a halfword from PCI configuration space.
export type fn_pci_readh = fn(dev: *pcidev, device: u32, offs: u8) u16;

// Function to read a byte from PCI configuration space.
export type fn_pci_readb = fn(dev: *pcidev, device: u32, offs: u8) u8;

// Function to write a long to PCI configuration space.
export type fn_pci_writel = fn(dev: *pcidev, device: u32, offs: u8, val: u64) void;

// Function to write a word to PCI configuration space.
export type fn_pci_writew = fn(dev: *pcidev, device: u32, offs: u8, val: u32) void;

// Function to write a halfword to PCI configuration space.
export type fn_pci_writeh = fn(dev: *pcidev, device: u32, offs: u8, val: u16) void;

// Function to write a byte to PCI configuration space.
export type fn_pci_writeb = fn(dev: *pcidev, device: u32, offs: u8, val: u8) void;

// PCI interface
export type pcidev_iface = struct {
	readl: *fn_pci_readl,
	readw: *fn_pci_readw,
	readh: *fn_pci_readh,
	readb: *fn_pci_readb,
	writel: *fn_pci_writel,
	writew: *fn_pci_writew,
	writeh: *fn_pci_writeh,
	writeb: *fn_pci_writeb,
};
