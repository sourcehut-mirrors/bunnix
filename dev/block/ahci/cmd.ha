use ata;
use errors::{error, errno};

// Prepares a command to readi the identification from the drive connected to an
// HBA port. The prdt list specifies the read buffer and must use physical
// memory addresses.
fn prep_identify(
	port: *ahci_port,
	prdt: (uintptr, size)...
) (*hba_cmd_table | error) = {
	let cmd = port_prepcmd(port, size(fis_reg_h2d), 0, prdt...)?;
	let fis = &cmd.cfis: *fis_reg_h2d;
	fis.fis_type = fis_type::REG_H2D;
	fis.pmport_c = 1 << 7;
	fis.command = ata::ATA_IDENTIFY_DEVICE;
	return cmd;
};

// Prepares a command to read a sector from the drive connected to an HBA port.
fn prep_read_dma_ext(
	port: *ahci_port,
	lba: size,
	prdt: (uintptr, size)...
) (*hba_cmd_table | error) = {
	let sum = 0z;
	for (let i = 0z; i < len(prdt); i += 1) {
		sum += prdt[i].1;
	};
	const sectors = sum / 512;

	let cmd = port_prepcmd(port, size(fis_reg_h2d), 0, prdt...)?;
	let fis = &cmd.cfis: *fis_reg_h2d;
	fis.fis_type = fis_type::REG_H2D;
	fis.pmport_c = 1 << 7;
	fis.command = ata::ATA_READ_DMA_EXT;

	fis.lba0 = lba: u8;
	fis.lba1 = (lba >> 8): u8;
	fis.lba2 = (lba >> 16): u8;
	fis.lba3 = (lba >> 24): u8;
	fis.lba4 = (lba >> 32): u8;
	fis.lba5 = (lba >> 40): u8;

	fis.device = 1 << 6; // LBA mode

	fis.countl = sectors: u8;
	fis.counth = (sectors >> 8): u8;
	return cmd;
};

// Prepares a command to write a sector to the drive connected to an HBA port.
fn prep_write_dma_ext(
	port: *ahci_port,
	lba: size,
	prdt: (uintptr, size)...
) (*hba_cmd_table | error) = {
	let sum = 0z;
	for (let i = 0z; i < len(prdt); i += 1) {
		sum += prdt[i].1;
	};
	const sectors = sum / 512;

	let cmd = port_prepcmd(port, size(fis_reg_h2d),
		HBA_CMD_W | HBA_CMD_P, prdt...)?;
	let fis = &cmd.cfis: *fis_reg_h2d;
	fis.fis_type = fis_type::REG_H2D;
	fis.pmport_c = 1 << 7;
	fis.command = ata::ATA_WRITE_DMA_EXT;

	fis.lba0 = lba: u8;
	fis.lba1 = (lba >> 8): u8;
	fis.lba2 = (lba >> 16): u8;
	fis.lba3 = (lba >> 24): u8;
	fis.lba4 = (lba >> 32): u8;
	fis.lba5 = (lba >> 40): u8;

	fis.device = 0x40 | 0xA0; // LBA mode

	fis.countl = sectors: u8;
	fis.counth = (sectors >> 8): u8;
	return cmd;
};
