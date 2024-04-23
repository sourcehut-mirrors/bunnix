use dev::pci;
use log;
use mman;

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
	const base = pci::mmap_device(info.bus, info.device, pci::bar::BAR5);
	let ghc = base: *hba_ghc;

	const version = ghc.vs;
	const major = ghc.vs >> 16;
	const minor = ghc.vs & 0xFFFF;
	log::printfln("AHCI controller version {}.{}", major, minor);

	// TODO: Initialize controller

	let pcidev = alloc(ahci_controller {
		driver = &ahci_driver,
		bus = info.bus,
	});

	return pcidev;
};
