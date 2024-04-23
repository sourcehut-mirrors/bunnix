use dev::pci;
use log;

def AHCI_PCI_CLASS: u16 = 0x0106;

const ahci_driver = pci::driver {
	name = "ahci",
	class = AHCI_PCI_CLASS,
	probe = &ahci_probe,
	next = null,
};

type ahci_controller = struct {
	pci::pcidev,
};

@init fn register() void = {
	pci::register_driver(&ahci_driver);
};

fn ahci_probe(info: *pci::probe_info) nullable *pci::pcidev = {
	log::println("AHCI probe");

	// TODO: Initialize controller

	let pcidev = alloc(ahci_controller {
		driver = &ahci_driver,
		bus = info.bus,
	});

	return pcidev;
};
