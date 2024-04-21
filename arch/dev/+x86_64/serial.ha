use arch::x86_64;
use cons;

export def SERIAL_PORT_A: u16 = 0x3F8;
export def SERIAL_PORT_B: u16 = 0x2F8;
export def SERIAL_PORT_C: u16 = 0x3E8;
export def SERIAL_PORT_D: u16 = 0x2E8;

export type serial_console = struct {
	cons: cons::console,
	port: u16,
};

// Initializes a serial console on the given port.
export fn serial_init(cons: *serial_console, port: u16) void = {
	cons.cons.write = &serial_write;
	cons.port = port;
	x86_64::outb(port + 1, 0x00); // Disable interrupts
	x86_64::outb(port + 3, 0x80); // Enable divisor mode
	x86_64::outb(port + 0, 0x01); // Div Low:  01 Set the port to 115200 bps
	x86_64::outb(port + 1, 0x00); // Div High: 00
	x86_64::outb(port + 3, 0x03); // Disable divisor mode, set parity
	x86_64::outb(port + 2, 0xC7); // Enable FIFO and clear
	cons::register(cons);
};

fn serial_ready(port: u16) bool = {
	return (x86_64::inb(port + 5) & 0x20) != 0;
};

fn serial_putc(cons: *serial_console, val: u8) void = {
	// TODO: Don't block forever here
	for (!serial_ready(cons.port)) void;
	x86_64::outb(cons.port, val);
};

fn serial_write(cons: *cons::console, buf: []u8) size = {
	let cons = cons: *serial_console;
	assert(cons.cons.write == &serial_write);
	for (let i = 0z; i < len(buf); i += 1) {
		if (buf[i] == '\n') {
			serial_putc(cons, '\r');
		};
		serial_putc(cons, buf[i]);
	};
	return len(buf);
};
