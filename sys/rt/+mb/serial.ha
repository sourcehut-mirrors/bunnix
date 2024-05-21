use arch::x86_64;

@init fn init() void = {
	serial_outb(COM1, IER,    0x00);   // Disable interrupts
	serial_outb(COM1, LCR,    0x80);   // Enable divisor mode
	serial_outb(COM1, DL_LSB, 0x01);   // Div Low:  01 Set the port to 115200 bps
	serial_outb(COM1, DL_MSB, 0x00);   // Div High: 00
	serial_outb(COM1, LCR,    0x03);   // Disable divisor mode, set parity
	serial_outb(COM1, FCR,    0xC7);   // Enable FIFO and clear
	serial_outb(COM1, MCR,    0x0B);   // Enable OUT1 & OUT2
};

fn serial_inb(port: u16, reg: u16) u8 = {
	return x86_64::inb(port + reg);
};

fn serial_outb(port: u16, reg: u16, val: u8) void = {
	x86_64::outb(port + reg, val);
};

fn serial_ready(port: u16) bool = {
	return (serial_inb(port, LSR) & THRE) != 0;
};

fn serial_putc(port: u16, val: u8) void = {
	for (!serial_ready(port)) void;
	serial_outb(port, THR, val);
};

fn serial_write(buf: const []u8) size = {
	for (let i = 0z; i < len(buf); i += 1) {
		if (buf[i] == '\n') {
			serial_putc(COM1, '\r');
		};
		serial_putc(COM1, buf[i]);
	};
	return len(buf);
};
