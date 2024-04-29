use arch::x86_64;
use dev::pci;

def PCI_CONF_ADDR: u16 = 0xCF8;
def PCI_CONF_DATA: u16 = 0xCFC;

export type pci_legacy = struct {
	pci::pcibus,
};

export let legacy_pci_bus = pci_legacy {
	bus = &pci::bus_impl,
	impl = &pci_impl,
};

const pci_impl = pci::pcibus_iface {
	readl = &pci_legacy_readl,
	readw = &pci_legacy_readw,
	readb = &pci_legacy_readb,
	writel = &pci_legacy_writel,
	writew = &pci_legacy_writew,
	writeb = &pci_legacy_writeb,
};

fn pci_addr(device: u32, offs: u8) u32 = {
	return 0x80000000u32
		| pci::device_bus(device): u32 << 16
		| pci::device_slot(device): u32 << 11
		| pci::device_func(device): u32 << 8
		| (offs & 0xFC);
};

fn pci_legacy_writeaddr(device: u32, offs: u8) void = {
	x86_64::outl(PCI_CONF_ADDR, pci_addr(device, offs));
};

fn pci_legacy_readl(bus: *pci::pcibus, device: u32, offs: u8) u32 = {
	pci_legacy_writeaddr(device, offs);
	return x86_64::inl(PCI_CONF_DATA);
};

fn pci_legacy_readw(bus: *pci::pcibus, device: u32, offs: u8) u16 = {
	pci_legacy_writeaddr(device, offs);
	return x86_64::inw(PCI_CONF_DATA + (offs & 2));
};

fn pci_legacy_readb(bus: *pci::pcibus, device: u32, offs: u8) u8 = {
	pci_legacy_writeaddr(device, offs);
	return x86_64::inb(PCI_CONF_DATA + (offs & 3));
};

fn pci_legacy_writel(bus: *pci::pcibus, device: u32, offs: u8, val: u32) void = {
	assert(offs % 4 == 0);
	pci_legacy_writeaddr(device, offs);
	x86_64::outl(PCI_CONF_DATA, val);
};

fn pci_legacy_writew(bus: *pci::pcibus, device: u32, offs: u8, val: u16) void = {
	pci_legacy_writeaddr(device, offs);
	x86_64::outw(PCI_CONF_DATA + (offs & 2), val);
};

fn pci_legacy_writeb(bus: *pci::pcibus, device: u32, offs: u8, val: u8) void = {
	pci_legacy_writeaddr(device, offs);
	x86_64::outb(PCI_CONF_DATA + (offs & 3), val);
};
