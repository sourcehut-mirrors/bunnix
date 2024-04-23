// PCI enumeration callback.
export type pci_func = fn(dev: *pcidev, device: u32, user: nullable *opaque = null) void;

// Scans the PCI bus for devices, calling the provided callback with each
// discovered device.
export fn scan(dev: *pcidev, scan: *pci_func, user: nullable *opaque) void = {
	if (readb(dev, 0, PCI_HEADER_TYPE) & 0x80 == 0) {
		scan_bus(dev, scan, user, 0);
	};

	// TODO: Scan PCI bridges
};

fn scan_bus(dev: *pcidev, scan: *pci_func, user: nullable *opaque, bus: u8) void = {
	for (let slot = 0u8; slot < 32; slot += 1) {
		scan_slot(dev, scan, user, bus, slot);
	};
};

fn scan_slot(
	dev: *pcidev,
	scan: *pci_func,
	user: nullable *opaque,
	bus: u8,
	slot: u8,
) void = {
	const pdevice = device(bus, slot, 0);
	if (readw(dev, pdevice, PCI_VENDOR_ID) == PCI_NONE) {
		return;
	};
	scan_func(dev, scan, user, bus, slot, 0);
	if (readb(dev, pdevice, PCI_HEADER_TYPE) == 0) {
		return;
	};
	for (let func = 0u8; func < 8; func += 1) {
		const pdevice = device(bus, slot, func);
		if (readw(dev, pdevice, PCI_VENDOR_ID) != PCI_NONE) {
			scan_func(dev, scan, user, bus, slot, func);
		};
	};
};

fn scan_func(
	dev: *pcidev,
	scan: *pci_func,
	user: nullable *opaque,
	bus: u8,
	slot: u8,
	func: u8,
) void = {
	// TODO: Check for bridges
	const device = device(bus, slot, func);
	scan(dev, device, user);
};
