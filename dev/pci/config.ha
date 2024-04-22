export def PCI_VENDOR_ID: u8 = 0x00;
export def PCI_DEVICE_ID: u8 = 0x02;
export def PCI_COMMAND: u8 = 0x04;
export def PCI_STATUS: u8 = 0x06;
export def PCI_REVISION_ID: u8 = 0x08;

export def PCI_PROG_IF: u8 = 0x09;
export def PCI_SUBCLASS: u8 = 0x0a;
export def PCI_CLASS: u8 = 0x0b;
export def PCI_CACHE_LINE_SIZE: u8 = 0x0c;
export def PCI_LATENCY_TIMER: u8 = 0x0d;
export def PCI_HEADER_TYPE: u8 = 0x0e;
export def PCI_BIST: u8 = 0x0f;
export def PCI_BAR0: u8 = 0x10;
export def PCI_BAR1: u8 = 0x14;
export def PCI_BAR2: u8 = 0x18;
export def PCI_BAR3: u8 = 0x1C;
export def PCI_BAR4: u8 = 0x20;
export def PCI_BAR5: u8 = 0x24;

export def PCI_INTERRUPT_LINE: u8 = 0x3C;
export def PCI_INTERRUPT_PIN: u8 = 0x3D;

export def PCI_SECONDARY_BUS: u8 = 0x19;

export def PCI_HEADER_TYPE_DEVICE: u8 = 0;
export def PCI_HEADER_TYPE_BRIDGE: u8 = 1;
export def PCI_HEADER_TYPE_CARDBUS: u8 = 2;

export def PCI_NONE: u32 = 0xFFFF;
