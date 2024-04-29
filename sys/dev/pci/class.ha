// PCI class information.
export type pci_class = struct {
	id: u8,
	name: str,
	subclass: []pci_subclass,
};

// PCI subclass information.
export type pci_subclass = struct {
	id: u8,
	name: str,
};

// Returns the human-friendly name of a PCI class/subclass pair.
export fn class_lookup(class: u16) (str, str) = {
	let pci_class = "unknown", pci_subclass = "unknown";
	for (let i = 0z; i < len(pci_class_table); i += 1) {
		const ent = &pci_class_table[i];
		if (class >> 8 == ent.id) {
			pci_class = ent.name;
			for (let j = 0z; j < len(ent.subclass); j += 1) {
				if (ent.subclass[j].id == class & 0xFF) {
					pci_subclass = ent.subclass[j].name;
					break;
				};
			};
			break;
		};
	};
	return (pci_class, pci_subclass);
};

// PCI class table.
export const pci_class_table: []pci_class = [
	pci_class {
		id = 0x00,
		name = "Unclassified device",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Non-VGA unclassified device",
			},
			pci_subclass {
				id = 0x01,
				name = "VGA compatible unclassified device",
			},
			pci_subclass {
				id = 0x05,
				name = "Image coprocessor",
			},
		],
	},
	pci_class {
		id = 0x01,
		name = "Mass storage controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "SCSI storage controller",
			},
			pci_subclass {
				id = 0x01,
				name = "IDE interface",
			},
			pci_subclass {
				id = 0x02,
				name = "Floppy disk controller",
			},
			pci_subclass {
				id = 0x03,
				name = "IPI bus controller",
			},
			pci_subclass {
				id = 0x04,
				name = "RAID bus controller",
			},
			pci_subclass {
				id = 0x05,
				name = "ATA controller",
			},
			pci_subclass {
				id = 0x06,
				name = "SATA controller",
			},
			pci_subclass {
				id = 0x07,
				name = "Serial Attached SCSI controller",
			},
			pci_subclass {
				id = 0x08,
				name = "Non-Volatile memory controller",
			},
			pci_subclass {
				id = 0x80,
				name = "Mass storage controller",
			},
		],
	},
	pci_class {
		id = 0x02,
		name = "Network controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Ethernet controller",
			},
			pci_subclass {
				id = 0x01,
				name = "Token ring network controller",
			},
			pci_subclass {
				id = 0x02,
				name = "FDDI network controller",
			},
			pci_subclass {
				id = 0x03,
				name = "ATM network controller",
			},
			pci_subclass {
				id = 0x04,
				name = "ISDN controller",
			},
			pci_subclass {
				id = 0x05,
				name = "WorldFip controller",
			},
			pci_subclass {
				id = 0x06,
				name = "PICMG controller",
			},
			pci_subclass {
				id = 0x07,
				name = "Infiniband controller",
			},
			pci_subclass {
				id = 0x08,
				name = "Fabric controller",
			},
			pci_subclass {
				id = 0x80,
				name = "Network controller",
			},
		],
	},
	pci_class {
		id = 0x03,
		name = "Display controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "VGA compatible controller",
			},
			pci_subclass {
				id = 0x01,
				name = "XGA compatible controller",
			},
			pci_subclass {
				id = 0x02,
				name = "3D controller",
			},
			pci_subclass {
				id = 0x80,
				name = "Display controller",
			},
		],
	},
	pci_class {
		id = 0x04,
		name = "Multimedia controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Multimedia video controller",
			},
			pci_subclass {
				id = 0x01,
				name = "Multimedia audio controller",
			},
			pci_subclass {
				id = 0x02,
				name = "Computer telephony device",
			},
			pci_subclass {
				id = 0x03,
				name = "Audio device",
			},
			pci_subclass {
				id = 0x80,
				name = "Multimedia controller",
			},
		],
	},
	pci_class {
		id = 0x05,
		name = "Memory controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "RAM memory",
			},
			pci_subclass {
				id = 0x01,
				name = "FLASH memory",
			},
			pci_subclass {
				id = 0x02,
				name = "CXL",
			},
			pci_subclass {
				id = 0x80,
				name = "Memory controller",
			},
		],
	},
	pci_class {
		id = 0x06,
		name = "Bridge",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Host bridge",
			},
			pci_subclass {
				id = 0x01,
				name = "ISA bridge",
			},
			pci_subclass {
				id = 0x02,
				name = "EISA bridge",
			},
			pci_subclass {
				id = 0x03,
				name = "MicroChannel bridge",
			},
			pci_subclass {
				id = 0x04,
				name = "PCI bridge",
			},
			pci_subclass {
				id = 0x05,
				name = "PCMCIA bridge",
			},
			pci_subclass {
				id = 0x06,
				name = "NuBus bridge",
			},
			pci_subclass {
				id = 0x07,
				name = "CardBus bridge",
			},
			pci_subclass {
				id = 0x08,
				name = "RACEway bridge",
			},
			pci_subclass {
				id = 0x09,
				name = "Semi-transparent PCI-to-PCI bridge",
			},
			pci_subclass {
				id = 0x0a,
				name = "InfiniBand to PCI host bridge",
			},
			pci_subclass {
				id = 0x80,
				name = "Bridge",
			},
		],
	},
	pci_class {
		id = 0x07,
		name = "Communication controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Serial controller",
			},
			pci_subclass {
				id = 0x01,
				name = "Parallel controller",
			},
			pci_subclass {
				id = 0x02,
				name = "Multiport serial controller",
			},
			pci_subclass {
				id = 0x03,
				name = "Modem",
			},
			pci_subclass {
				id = 0x04,
				name = "GPIB controller",
			},
			pci_subclass {
				id = 0x05,
				name = "Smard Card controller",
			},
			pci_subclass {
				id = 0x80,
				name = "Communication controller",
			},
		],
	},
	pci_class {
		id = 0x08,
		name = "Generic system peripheral",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "PIC",
			},
			pci_subclass {
				id = 0x01,
				name = "DMA controller",
			},
			pci_subclass {
				id = 0x02,
				name = "Timer",
			},
			pci_subclass {
				id = 0x03,
				name = "RTC",
			},
			pci_subclass {
				id = 0x04,
				name = "PCI Hot-plug controller",
			},
			pci_subclass {
				id = 0x05,
				name = "SD Host controller",
			},
			pci_subclass {
				id = 0x06,
				name = "IOMMU",
			},
			pci_subclass {
				id = 0x80,
				name = "System peripheral",
			},
			pci_subclass {
				id = 0x99,
				name = "Timing Card",
			},
		],
	},
	pci_class {
		id = 0x09,
		name = "Input device controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Keyboard controller",
			},
			pci_subclass {
				id = 0x01,
				name = "Digitizer Pen",
			},
			pci_subclass {
				id = 0x02,
				name = "Mouse controller",
			},
			pci_subclass {
				id = 0x03,
				name = "Scanner controller",
			},
			pci_subclass {
				id = 0x04,
				name = "Gameport controller",
			},
			pci_subclass {
				id = 0x80,
				name = "Input device controller",
			},
		],
	},
	pci_class {
		id = 0x0a,
		name = "Docking station",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Generic Docking Station",
			},
			pci_subclass {
				id = 0x80,
				name = "Docking Station",
			},
		],
	},
	pci_class {
		id = 0x0b,
		name = "Processor",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "386",
			},
			pci_subclass {
				id = 0x01,
				name = "486",
			},
			pci_subclass {
				id = 0x02,
				name = "Pentium",
			},
			pci_subclass {
				id = 0x10,
				name = "Alpha",
			},
			pci_subclass {
				id = 0x20,
				name = "Power PC",
			},
			pci_subclass {
				id = 0x30,
				name = "MIPS",
			},
			pci_subclass {
				id = 0x40,
				name = "Co-processor",
			},
		],
	},
	pci_class {
		id = 0x0c,
		name = "Serial bus controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "FireWire (IEEE 1394)",
			},
			pci_subclass {
				id = 0x01,
				name = "ACCESS Bus",
			},
			pci_subclass {
				id = 0x02,
				name = "SSA",
			},
			pci_subclass {
				id = 0x03,
				name = "USB controller",
			},
			pci_subclass {
				id = 0x04,
				name = "Fibre Channel",
			},
			pci_subclass {
				id = 0x05,
				name = "SMBus",
			},
			pci_subclass {
				id = 0x06,
				name = "InfiniBand",
			},
			pci_subclass {
				id = 0x07,
				name = "IPMI Interface",
			},
			pci_subclass {
				id = 0x08,
				name = "SERCOS interface",
			},
			pci_subclass {
				id = 0x09,
				name = "CANBUS",
			},
			pci_subclass {
				id = 0x80,
				name = "Serial bus controller",
			},
		],
	},
	pci_class {
		id = 0x0d,
		name = "Wireless controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "IRDA controller",
			},
			pci_subclass {
				id = 0x01,
				name = "Consumer IR controller",
			},
			pci_subclass {
				id = 0x10,
				name = "RF controller",
			},
			pci_subclass {
				id = 0x11,
				name = "Bluetooth",
			},
			pci_subclass {
				id = 0x12,
				name = "Broadband",
			},
			pci_subclass {
				id = 0x20,
				name = "802.1a controller",
			},
			pci_subclass {
				id = 0x21,
				name = "802.1b controller",
			},
			pci_subclass {
				id = 0x80,
				name = "Wireless controller",
			},
		],
	},
	pci_class {
		id = 0x0e,
		name = "Intelligent controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "I2O",
			},
		],
	},
	pci_class {
		id = 0x0f,
		name = "Satellite communications controller",
		subclass = [
			pci_subclass {
				id = 0x01,
				name = "Satellite TV controller",
			},
			pci_subclass {
				id = 0x02,
				name = "Satellite audio communication controller",
			},
			pci_subclass {
				id = 0x03,
				name = "Satellite voice communication controller",
			},
			pci_subclass {
				id = 0x04,
				name = "Satellite data communication controller",
			},
		],
	},
	pci_class {
		id = 0x10,
		name = "Encryption controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Network and computing encryption device",
			},
			pci_subclass {
				id = 0x10,
				name = "Entertainment encryption device",
			},
			pci_subclass {
				id = 0x80,
				name = "Encryption controller",
			},
		],
	},
	pci_class {
		id = 0x11,
		name = "Signal processing controller",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "DPIO module",
			},
			pci_subclass {
				id = 0x01,
				name = "Performance counters",
			},
			pci_subclass {
				id = 0x10,
				name = "Communication synchronizer",
			},
			pci_subclass {
				id = 0x20,
				name = "Signal processing management",
			},
			pci_subclass {
				id = 0x80,
				name = "Signal processing controller",
			},
		],
	},
	pci_class {
		id = 0x12,
		name = "Processing accelerators",
		subclass = [
			pci_subclass {
				id = 0x00,
				name = "Processing accelerators",
			},
			pci_subclass {
				id = 0x01,
				name = "SNIA Smart Data Accelerator Interface (SDXI) controller",
			},
		],
	},
	pci_class {
		id = 0x13,
		name = "Non-Essential Instrumentation",
		subclass = [],
	},
	pci_class {
		id = 0x40,
		name = "Coprocessor",
		subclass = [],
	},
	pci_class {
		id = 0xff,
		name = "Unassigned class",
		subclass = [],
	},
];

