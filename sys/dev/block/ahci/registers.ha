type hba_ghc = struct {
	cap: u32,
	ghc: u32,
	_is: u32,
	pi: u32,
	vs: u32,
	ccc_ctl: u32,
	ccc_pts: u32,
	em_loc: u32,
	em_ctl: u32,
	cap2: u32,
	bohc: u32,
	reserved: [0x74]u8,
	vendor: [0x60]u8,
	ports: [*]hba_port,
};

type hba_port = struct {
	clb: u32,
	clbu: u32,
	fb: u32,
	fbu: u32,
	_is: u32,
	ie: u32,
	cmd: u32,
	rsv0: u32,
	tfd: u32,
	sig: u32,
	ssts: u32,
	sctl: u32,
	serr: u32,
	sact: u32,
	ci: u32,
	sntf: u32,
	fbs: u32,
	reserved: [11]u32,
	vendor: [4]u32,
};

// ATAPI flag
def HBA_CMD_A: u16 = 1 << 5;
// Write flag
def HBA_CMD_W: u16 = 1 << 6;
// Pre-fetchable flag
def HBA_CMD_P: u16 = 1 << 7;
// Reset flag
def HBA_CMD_R: u16 = 1 << 8;
// BIST flag
def HBA_CMD_B: u16 = 1 << 9;
// Clear busy flag
def HBA_CMD_C: u16 = 1 << 10;

type hba_cmd_header = struct {
	dw0: u16,
	prdtl: u16,
	prdbc: u32,
	ctba: u32,
	ctbau: u32,
	rsv: [4]u32,
};

type hba_cmd_table = struct {
	cfis: [64]u8,
	acmd: [16]u8,
	rsv: [48]u8,
	prdt: [8]hba_prdt,
};

type hba_prdt = struct {
	dba: u32,
	dbau: u32,
	rsv0: u32,
	dbci: u32,
};

type hba_fis = struct {
	dsfis: fis_dma_setup,
	pad0: [4]u8,

	psfis: fis_pio_setup,
	pad1: [12]u8,

	rfis: fis_reg_d2h,
	pad2: [4]u8,

	sdbfis: [8]u8,
	ufis: [64]u8,

	rsv: [0x60]u8,
};

def HBA_GHC_AE: u32 = (1 << 31);
def HBA_GHC_MSRM: u32 = (1 << 2);
def HBA_GHC_IE: u32 = (1 << 1);
def HBA_GHC_HR: u32 = (1 << 0);

def HBA_CAP_NP_BIT: u32 = 0;
def HBA_CAP_NP_MASK: u32 = 0b1111 << HBA_CAP_NP_BIT;
def HBA_CAP_SXS: u32 = 1 << 5;
def HBA_CAP_EMS: u32 = 1 << 6;
def HBA_CAP_CCCS: u32 = 1 << 7;
def HBA_CAP_NCS_BIT: u32 = 8;
def HBA_CAP_NCS_MASK: u32 = 0b1111 << HBA_CAP_NCS_BIT;
def HBA_CAP_PSC: u32 = 1 << 13;
def HBA_CAP_SSC: u32 = 1 << 14;
def HBA_CAP_PMD: u32 = 1 << 15;
def HBA_CAP_FBSS: u32 = 1 << 16;
def HBA_CAP_SPM: u32 = 1 << 17;
def HBA_CAP_SAM: u32 = 1 << 18;
def HBA_CAP_ISS_BIT: u32 = 20;
def HBA_CAP_ISS_MASK: u32 = 0b1111 << HBA_CAP_ISS_BIT;
def HBA_CAP_SCLO: u32 = 1 << 24;
def HBA_CAP_SAL: u32 = 1 << 25;
def HBA_CAP_SALP: u32 = 1 << 26;
def HBA_CAP_SSS: u32 = 1 << 27;
def HBA_CAP_SMPS: u32 = 1 << 28;
def HBA_CAP_SSNTF: u32 = 1 << 29;
def HBA_CAP_SNCQ: u32 = 1 << 30;
def HBA_CAP_S64A: u32 = 1 << 31;

def HBA_CAP2_BOH: u32 = 1 << 0;
def HBA_CAP2_NVMP: u32 = 1 << 1;
def HBA_CAP2_APST: u32 = 1 << 2;
def HBA_CAP2_SDS: u32 = 1 << 3;
def HBA_CAP2_SADM: u32 = 1 << 4;
def HBA_CAP2_DESO: u32 = 1 << 5;

def HBA_BOHC_BOS: u32 = 1 << 0;
def HBA_BOHC_OOS: u32 = 1 << 1;
def HBA_BOHC_SOOE: u32 = 1 << 2;
def HBA_BOHC_OOC: u32 = 1 << 3;
def HBA_BOHC_BB: u32 = 1 << 4;

def HBA_PxCMD_ST: u32 = 1 << 0;
def HBA_PxCMD_SUD: u32 = 1 << 1;
def HBA_PxCMD_POD: u32 = 1 << 2;
def HBA_PxCMD_CLO: u32 = 1 << 3;
def HBA_PxCMD_FRE: u32 = 1 << 4;
def HBA_PxCMD_CCS: u32 = 1 << 8;
def HBA_PxCMD_MPSS: u32 = 1 << 13;
def HBA_PxCMD_FR: u32 = 1 << 14;
def HBA_PxCMD_CR: u32 = 1 << 15;
def HBA_PxCMD_CPS: u32 = 1 << 16;
def HBA_PxCMD_PMA: u32 = 1 << 17;
def HBA_PxCMD_HPCP: u32 = 1 << 18;
def HBA_PxCMD_MPSP: u32 = 1 << 19;
def HBA_PxCMD_CPD: u32 = 1 << 20;
def HBA_PxCMD_ESP: u32 = 1 << 21;
def HBA_PxCMD_FBSCP: u32 = 1 << 22;
def HBA_PxCMD_APSTE: u32 = 1 << 23;
def HBA_PxCMD_ATAPI: u32 = 1 << 24;
def HBA_PxCMD_DLAE: u32 = 1 << 25;
def HBA_PxCMD_ALPE: u32 = 1 << 26;
def HBA_PxCMD_ASP: u32 = 1 << 27;
def HBA_PxCMD_ICC: u32 = 1 << 28;

def HBA_PxIS_DHRS: u32 = 1 << 0;
def HBA_PxIS_PSS: u32 = 1 << 1;
def HBA_PxIS_DSS: u32 = 1 << 2;
def HBA_PxIS_SDBS: u32 = 1 << 3;
def HBA_PxIS_UFS: u32 = 1 << 4;
def HBA_PxIS_DPS: u32 = 1 << 5;
def HBA_PxIS_PCS: u32 = 1 << 6;
def HBA_PxIS_DPMS: u32 = 1 << 7;
def HBA_PxIS_PRCS: u32 = 1 << 22;
def HBA_PxIS_IPMS: u32 = 1 << 23;
def HBA_PxIS_OFS: u32 = 1 << 24;
def HBA_PxIS_INFS: u32 = 1 << 26;
def HBA_PxIS_IFS: u32 = 1 << 27;
def HBA_PxIS_HBDS: u32 = 1 << 28;
def HBA_PxIS_HBFS: u32 = 1 << 29;
def HBA_PxIS_TFES: u32 = 1 << 30;
def HBA_PxIS_CPDS: u32 = 1 << 31;

def HBA_PxIE_DHRE: u32 = 1 << 0;
def HBA_PxIE_PSE: u32 = 1 << 1;
def HBA_PxIE_DSE: u32 = 1 << 2;
def HBA_PxIE_SDBE: u32 = 1 << 3;
def HBA_PxIE_UFE: u32 = 1 << 4;
def HBA_PxIE_DPE: u32 = 1 << 5;
def HBA_PxIE_PCE: u32 = 1 << 6;
def HBA_PxIE_DPME: u32 = 1 << 7;
def HBA_PxIE_PRCE: u32 = 1 << 22;
def HBA_PxIE_IPME: u32 = 1 << 23;
def HBA_PxIE_OFE: u32 = 1 << 24;
def HBA_PxIE_INFE: u32 = 1 << 26;
def HBA_PxIE_IFE: u32 = 1 << 27;
def HBA_PxIE_HBDE: u32 = 1 << 28;
def HBA_PxIE_HBFE: u32 = 1 << 29;
def HBA_PxIE_TFEE: u32 = 1 << 30;
def HBA_PxIE_CPDE: u32 = 1 << 31;

// Interrupts enabled mask
def HBA_PxIE_IEM: u32 =
	HBA_PxIE_DHRE |
	HBA_PxIE_PSE |
	HBA_PxIE_DSE |
	HBA_PxIE_SDBE |
	HBA_PxIE_UFE |
	HBA_PxIE_DPE |
	HBA_PxIE_PCE |
	HBA_PxIE_DPME |
	HBA_PxIE_PRCE |
	HBA_PxIE_IPME |
	HBA_PxIE_OFE |
	HBA_PxIE_IFE |
	HBA_PxIE_HBDE |
	HBA_PxIE_HBFE |
	HBA_PxIE_TFEE |
	HBA_PxIE_CPDE;

def HBA_PxIS_FATAL: u32 =
	HBA_PxIS_HBFS |
	HBA_PxIS_HBDS |
	HBA_PxIS_IFS;

def PORT_SSTS_DET_MASK: u32 = 0b1111;
def PORT_SSTS_DET_NODEV: u32 = 0;
def PORT_SSTS_DET_NOPHY: u32 = 1;
def PORT_SSTS_DET_PRESENT: u32 = 3;
def PORT_SSTS_DET_OFFLINE: u32 = 4;

def PORT_SSTS_IPM_ACTIVE: u8 = 1;

def PORT_TFD_STS_MASK: u32 = 0b1111111;
def PORT_TFD_STS_ERR: u32 = 1 << 0;
def PORT_TFD_STS_DRQ: u32 = 3 << 0;
def PORT_TFD_STS_BSY: u32 = 7 << 0;
