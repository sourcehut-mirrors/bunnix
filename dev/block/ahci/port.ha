use dev::block;
use errors::{error, errno};
use log;
use mman;
use rt;
use sched;
use time;

type ahci_port = struct {
	block::blockdev,
	base: *ahci_controller,
	port: *hba_port,
	sectors: size,
	devtype: devtype,
	mmio: *ahci_port_mmio,
};

type ahci_port_mmio = struct {
	cmdlist: [32]hba_cmd_header,
	cmdtable: [32]hba_cmd_table,
	fis: hba_fis,
};

// Initializes and spins up a port on the HBA. Returns null if no device is
// connected to this port.
fn port_init(
	dev: *ahci_controller,
	hba_port: *hba_port,
	portno: u32,
) nullable *ahci_port = {
	port_idle(hba_port);

	const base = mman::mmap(&mman::kernel, 0, 0,
		size(ahci_port),
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON | mman::flag::CD)!;
	assert(base != null && base % 1024 == 0);
	const phys = mman::mmap_phys(&mman::kernel, base);

	let mmio = base: *ahci_port_mmio;
	let port = alloc(ahci_port {
		impl = &bdev_impl,
		iface = block::interface::SATA,
		blocksz = SECTORSZ,
		mmio = mmio,
		base = dev,
		port = hba_port,
		...
	});

	const s64a = dev.hba.cap & HBA_CAP_S64A != 0;
	assert(s64a || phys & ~((1 << 32) - 1) == 0,
		"32-bit AHCI support not implemented"); // TODO

	// Command list
	const clb = phys + offset(mmio.cmdlist): uintptr;
	hba_port.clb = clb: u32;
	hba_port.clbu = (clb >> 32): u32;

	// Command table
	for (let i = 0u32; i < dev.slots; i += 1) {
		let header = &mmio.cmdlist[i];
		header.prdtl = 8;
		const ctb = phys + offset(mmio.cmdtable): uintptr +
			(i * size(hba_cmd_table)): uintptr;
		header.ctba = ctb: u32;
		header.ctbau = (ctb >> 32): u32;
	};

	// FIS
	const fis = phys + offset(mmio.fis): uintptr;
	hba_port.fb = fis: u32;
	hba_port.fbu = (fis >> 32): u32;

	// Test for staggered spin-up support
	if (dev.hba.cap & HBA_CAP_SSS == 0) {
		const dtype = port_devtype(hba_port);
		if (dtype == devtype::NULL) {
			return null;
		};

		port.devtype = dtype;
		port_start(hba_port);
		return port;
	};

	// Spin up the port
	log::kprintfln(AHCI, "Initiated spin-up on port {}", portno);
	hba_port.cmd |= HBA_PxCMD_FRE;
	hba_port.cmd |= HBA_PxCMD_SUD | HBA_PxCMD_POD;

	let i = 0z;
	for (i < 1400; i += 50) {
		const det = hba_port.ssts & PORT_SSTS_DET_MASK;
		if (det == PORT_SSTS_DET_NOPHY || det == PORT_SSTS_DET_PRESENT) {
			break;
		};
		time::sleep(50 * time::MILLISECOND);
	};
	if (i == 1400) {
		return null;
	};

	// Clear port errors
	hba_port.serr = ~0;

	for (true) {
		const sts = hba_port.tfd & PORT_TFD_STS_MASK;
		const mask = PORT_TFD_STS_ERR |
			PORT_TFD_STS_DRQ | PORT_TFD_STS_BSY;
		if (sts & mask == 0) {
			break;
		};
	};

	port_start(hba_port);
	port.devtype = port_devtype(hba_port);
	return port;
};

// Puts an HBA port into an idle state.
fn port_idle(port: *hba_port) void = {
	// TODO: Should do some timeouts here
	const stmask = HBA_PxCMD_ST | HBA_PxCMD_CR
		| HBA_PxCMD_FRE | HBA_PxCMD_FR;
	if (port.cmd & stmask == 0) {
		return;
	};

	if (port.cmd & HBA_PxCMD_ST != 0) {
		port.cmd &= ~HBA_PxCMD_ST;
		for (port.cmd & HBA_PxCMD_CR != 0) sched::yieldtask();
	};

	if (port.cmd & HBA_PxCMD_FRE != 0) {
		port.cmd &= ~HBA_PxCMD_FRE;
		for (port.cmd & HBA_PxCMD_FR != 0) sched::yieldtask();
	};
};

fn port_start(port: *hba_port) void = {
	for (port.cmd & HBA_PxCMD_CR != 0) sched::yieldtask();
	port.cmd |= HBA_PxCMD_FRE;
	port.cmd |= HBA_PxCMD_ST;
};

fn port_devtype(port: *hba_port) devtype = {
	const ssts = port.ssts;
	const ipm = ssts >> 8 & 0xF;
	const det = ssts & 0xF;
	if (det != PORT_SSTS_DET_PRESENT) {
		return devtype::NULL;
	};
	if (ipm != PORT_SSTS_IPM_ACTIVE) {
		return devtype::NULL;
	};

	switch (port.sig) {
	case SATA_SIG_ATAPI =>
		return devtype::SATAPI;
	case SATA_SIG_SEMB =>
		return devtype::SEMB;
	case SATA_SIG_PM =>
		return devtype::PM;
	case =>
		return devtype::SATA;
	};
};

// Returns a free slot index from this port.
fn port_getslot(port: *ahci_port) (u32 | error) = {
	const hba_port = port.port;
	const inuse = hba_port.sact | hba_port.ci;
	for (let i = 0u32; i < port.base.slots; i += 1) {
		if (inuse & (1 << i) == 0) {
			return i;
		};
	};
	return errno::BUSY: error;
};

// Waits until the port is ready to accept a new command.
fn port_wait(port: *ahci_port) void = {
	const busy = PORT_TFD_STS_DRQ | PORT_TFD_STS_BSY;
	for (port.port.tfd & busy != 0) sched::yieldtask();
};

// Prepares a command for an HBA port.
fn port_prepcmd(
	port: *ahci_port,
	cmdsz: size,
	flags: u16,
	prdt: (uintptr, size)...
) (*hba_cmd_table | error) = {
	const slot = port_getslot(port)?;
	let header = &port.mmio.cmdlist[slot];

	const nprdt = len(prdt): u16;
	const dw0 =
		flags |				// Flags
		(cmdsz / size(u32)): u16;
	header.dw0 = dw0;
	header.prdtl = nprdt;
	header.prdbc = 0;

	let cmd = &port.mmio.cmdtable[slot];
	rt::memset(cmd, 0, size(hba_cmd_table));
	for (let i = 0z; i < len(prdt); i += 1) {
		const (phys, ln) = prdt[i];
		cmd.prdt[i].dba = phys: u32;
		cmd.prdt[i].dbau = (phys >> 32): u32;
		assert(ln <= 4194304); // 4 MiB max
		assert(ln % 2 == 0);
		cmd.prdt[i].dbci = (ln - 1): u32 | 1;
	};

	return cmd;
};

// Submits a command to the HBA for processing.
fn port_submitcmd(port: *ahci_port, cmd: *hba_cmd_table) void = {
	const slot = ((cmd: uintptr - &port.mmio.cmdtable: uintptr): size
		/ size(hba_cmd_table)): u32;
	port.port._is = ~0;
	port.port.ci |= 1 << slot;
};

fn port_waitcmd(port: *ahci_port, cmd: *hba_cmd_table) void = {
	const slot = ((cmd: uintptr - &port.mmio.cmdtable: uintptr): size
		/ size(hba_cmd_table)): u32;
	for (port.port.ci & (1 << slot) != 0) sched::yieldtask();
};
