use arch;

// PCI device
export type pcidev = struct {
	driver: const *driver,
	bus: const *pcibus,
	device: u32,
};

// Installs an IRQ handler for a given PCI device
export fn install_irq(
	dev: *pcidev,
	handler: *arch::irq_handler,
	func: *arch::irq_handler_func,
	user: nullable *opaque = null,
) void = {
	const irq = readb(dev.bus, dev.device, PCI_INTERRUPT_LINE);
	arch::install_irq(handler, irq, func, user);
};
