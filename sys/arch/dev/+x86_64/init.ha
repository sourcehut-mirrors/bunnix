use dev;
use log;

// Initialize architecture-specific devices.
export fn init() void = {
	// TODO: Grab ACPI and look for PCIe
	dev::bus_register(&legacy_pci_bus);
};
