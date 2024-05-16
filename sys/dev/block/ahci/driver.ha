use arch;
use dev::pci;
use log;
use mman;
use sched;

const AHCI: str = "ahci";

def AHCI_PCI_CLASS: u16 = 0x0106;

const ahci_driver = pci::driver {
	name = "ahci",
	class = AHCI_PCI_CLASS,
	probe = &ahci_probe,
	next = null,
};

type ahci_controller = struct {
	pci::pcidev,
	hba: *hba_ghc,
	pool: *buffer_pool,
	ports: [32]nullable *ahci_port,
	slots: u32,
	irq: arch::irq_handler,
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
	log::kprintfln(AHCI, "AHCI controller version {}.{} mapped to {}",
		major, minor, ghc);

	const pool = buffer_pool_init();

	let cont = alloc(ahci_controller {
		driver = &ahci_driver,
		pool = pool,
		bus = info.bus,
		device = info.device,
		hba = ghc,
		...
	});
	pci::install_irq(cont, &cont.irq, &ahci_irq, cont);
	hba_init(cont);
	return cont;
};

fn ahci_irq(irq: u8, user: nullable *opaque) void = {
	defer arch::irq_ack(irq);

	let cont = user: *ahci_controller;
	let hba = cont.hba;
	const _is = hba._is;
	for (let i = 0u32; i < 32; i += 1) {
		if (_is & (1 << i) == 0) {
			continue;
		};
		match (cont.ports[i]) {
		case let port: *ahci_port =>
			sched::wake(&port.wq);
		case null =>
			log::kprintfln(AHCI, "Warning: received IRQ for disabled port");
			continue;
		};
	};
	hba._is = ~0;
};
