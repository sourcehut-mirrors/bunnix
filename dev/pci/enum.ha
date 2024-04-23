use dev;
use log;

export const bus_impl = dev::bus_iface {
	scan = &pci_scan,
};

fn pci_scan(bus: *dev::bus) void = {
	const dev = bus: *pcibus;
	log::kprintln(PCI, "Begin device enumeration");
	if (readb(dev, 0, PCI_HEADER_TYPE) & 0x80 == 0) {
		scan_bus(dev, 0);
	};

	// TODO: Scan bridges
};

fn scan_bus(dev: *pcibus, bus: u8) void = {
	for (let slot = 0u8; slot < 32; slot += 1) {
		scan_slot(dev, bus, slot);
	};
};

fn scan_slot(
	dev: *pcibus,
	bus: u8,
	slot: u8,
) void = {
	const pdevice = device(bus, slot, 0);
	if (readw(dev, pdevice, PCI_VENDOR_ID) == PCI_NONE) {
		return;
	};
	scan_func(dev, bus, slot, 0);
	if (readb(dev, pdevice, PCI_HEADER_TYPE) == 0) {
		return;
	};
	for (let func = 0u8; func < 8; func += 1) {
		const pdevice = device(bus, slot, func);
		if (readw(dev, pdevice, PCI_VENDOR_ID) != PCI_NONE) {
			scan_func(dev, bus, slot, func);
		};
	};
};

fn scan_func(
	dev: *pcibus,
	bus: u8,
	slot: u8,
	func: u8,
) void = {
	const device = device(bus, slot, func);
	probe(dev, device);
};
