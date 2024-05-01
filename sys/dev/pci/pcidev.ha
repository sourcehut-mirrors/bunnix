use arch;

// PCI device
export type pcidev = struct {
	driver: const *driver,
	bus: const *pcibus,
};
