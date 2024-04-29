use arch::x86_64;

def PIC1: u16 = 0x20;
def PIC2: u16 = 0xA0;
def PIC1_CMD: u16 = PIC1;
def PIC1_DATA: u16 = PIC1 + 1;
def PIC2_CMD: u16 = PIC2;
def PIC2_DATA: u16 = PIC2 + 1;

def PIC_EOI: u8 = 0x20;

def PIC1_OFFS: u8 = 0x20;
def PIC2_OFFS: u8 = 0x28;

def ICW1_ICW4: u8 = 0x01;
def ICW1_INIT: u8 = 0x10;
def ICW4_8086: u8 = 0x01;

// Sends an End of Interrupt command to the PIC.
export fn pic_eoi(irq: u8) void = {
	if (irq >= 8) {
		x86_64::outb(PIC2_CMD, PIC_EOI);
	};
	x86_64::outb(PIC1_CMD, PIC_EOI);
};

fn pic_wait() void = for (let i = 0z; i < 8; i += 1) void;

export fn init_pic() void = {
	pic_remap(PIC1_OFFS, PIC2_OFFS);
};

// Remaps the PIC interrupt ranges.
export fn pic_remap(offs1: u8, offs2: u8) void = {
	x86_64::outb(PIC1_CMD, ICW1_INIT | ICW1_ICW4);
	pic_wait();
	x86_64::outb(PIC2_CMD, ICW1_INIT | ICW1_ICW4);
	pic_wait();

	x86_64::outb(PIC1_DATA, offs1);
	pic_wait();
	x86_64::outb(PIC2_DATA, offs2);
	pic_wait();

	// Slave PIC2 to PIC1
	x86_64::outb(PIC1_DATA, 4);
	pic_wait();
	x86_64::outb(PIC2_DATA, 2);
	pic_wait();

	x86_64::outb(PIC1_DATA, ICW4_8086);
	pic_wait();
	x86_64::outb(PIC2_DATA, ICW4_8086);
	pic_wait();

	// Mask all interrupts
	x86_64::outb(PIC1_DATA, 0b11111011);
	x86_64::outb(PIC2_DATA, 0b11111111);
};

// Disables an interrupt on the PIC.
export fn pic_mask(line: u8) void = {
	const port = if (line < 8) {
		yield PIC1_DATA;
	} else {
		line -= 8;
		yield PIC2_DATA;
	};
	const mask = x86_64::inb(port) | 1 << line;
	x86_64::outb(port, mask);
};

// Enables an interrupt on the PIC.
export fn pic_unmask(line: u8) void = {
	const port = if (line < 8) {
		yield PIC1_DATA;
	} else {
		line -= 8;
		yield PIC2_DATA;
	};
	const mask = x86_64::inb(port) & ~(1 << line);
	x86_64::outb(port, mask);
};
