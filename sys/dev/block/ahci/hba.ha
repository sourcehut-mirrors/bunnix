use arch;
use ata;
use dev::block;
use errors::{error, errno};
use log;
use time;

// Resets and initializes the HBA.
fn hba_init(dev: *ahci_controller) void = {
	let hba = dev.hba;
	hba_enable_ahci(hba);

	if (hba.cap2 & HBA_CAP2_BOH != 0) {
		hba_do_bios_handoff(hba);
	};

	hba_reset(hba);
	hba_enable_ahci(hba);

	dev.slots = hba.cap & HBA_CAP_NCS_MASK >> HBA_CAP_NCS_BIT;
	for (let i = 0u32; i < 32; i += 1) {
		const present = hba.pi & 1 << i != 0;
		if (!present) {
			continue;
		};
		const port = port_init(dev, &hba.ports[i], i);
		dev.ports[i] = port;

		if (port == null) {
			continue;
		};
		const port = port as *ahci_port;
		time::sleep(50 * time::MILLISECOND);

		// ATA IDENTIFY DEVICE
		const buffer = getbuffer(dev.pool, 1)!;
		defer releasebuffer(dev.pool, &buffer);

		let cmd = prep_identify(port, buffer.prdt)!;
		port_wait(port);
		port_submitcmd(port, cmd);
		match (port_waitcmd(port, cmd)) {
		case error =>
			log::kprintfln(log::WARN,
				"Warning: AHCI port {} IDENTIFY failed, disabling port",
				i);
			dev.ports[i] = null;
			continue;
		case void => void;
		};

		let id = ata::ident { ... };
		ata::decode_ident(buffer.data, &id);
		port.blocks = id.sectors;
		log::kprintfln(AHCI, "Port {}: {} : SN {} : {} sectors",
			i, id.model, id.serial, id.sectors);
		block::register(port);
	};

	hba_enable_irq(hba);
};

// Enable AHCI support.
fn hba_enable_ahci(hba: *hba_ghc) void = {
	hba.ghc |= HBA_GHC_AE;
};

// Initiates a controller reset.
fn hba_reset(hba: *hba_ghc) void = {
	log::kprintln(AHCI, "AHCI controller reset");
	hba.ghc |= HBA_GHC_HR;
	for (hba.ghc & HBA_GHC_HR != 0) {
		arch::pause();
	};
};

// Performs the BIOS hand-off procedure.
fn hba_do_bios_handoff(hba: *hba_ghc) void = {
	log::kprintln(AHCI, "Initiate BIOS handoff");
	if (hba.cap & HBA_BOHC_BOS == 0) {
		return;
	};
	hba.bohc |= HBA_BOHC_OOS;
	for (hba.bohc & HBA_BOHC_BOS != 0) {
		arch::pause();
	};
};

// Enables interrupts on the controller.
fn hba_enable_irq(hba: *hba_ghc) void = {
	hba._is = ~0;
	hba.ghc |= HBA_GHC_IE;
};
