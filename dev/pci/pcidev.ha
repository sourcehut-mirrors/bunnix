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
export type pci_readl_func = fn(dev: *pcidev, device: u32, offs: u8) u64;

// Function to read a word from PCI configuration space.
export type pci_readw_func = fn(dev: *pcidev, device: u32, offs: u8) u32;

// Function to read a halfword from PCI configuration space.
export type pci_readh_func = fn(dev: *pcidev, device: u32, offs: u8) u16;

// Function to read a byte from PCI configuration space.
export type pci_readb_func = fn(dev: *pcidev, device: u32, offs: u8) u8;

// Function to write a long to PCI configuration space.
export type pci_writel_func = fn(dev: *pcidev, device: u32, offs: u8, val: u64) void;

// Function to write a word to PCI configuration space.
export type pci_writew_func = fn(dev: *pcidev, device: u32, offs: u8, val: u32) void;

// Function to write a halfword to PCI configuration space.
export type pci_writeh_func = fn(dev: *pcidev, device: u32, offs: u8, val: u16) void;

// Function to write a byte to PCI configuration space.
export type pci_writeb_func = fn(dev: *pcidev, device: u32, offs: u8, val: u8) void;

// PCI interface
export type pcidev_iface = struct {
	readl: *pci_readl_func,
	readw: *pci_readw_func,
	readh: *pci_readh_func,
	readb: *pci_readb_func,
	writel: *pci_writel_func,
	writew: *pci_writew_func,
	writeh: *pci_writeh_func,
	writeb: *pci_writeb_func,
};
