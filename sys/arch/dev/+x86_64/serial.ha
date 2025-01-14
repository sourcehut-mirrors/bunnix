use arch;
use arch::x86_64;
use dev::chr;
use errors::{error, errno};
use io;
use sched;

export type pcserial = struct {
	chr::serialdev,
	irq: [2]arch::irq_handler,
	port: u16,
	wq: sched::wq_head,
};

def IRQ3 = 3;
def IRQ4 = 4;

// Initializes a serial console on the given port.
export fn serial_init(dev: *pcserial, port: u16) void = {
	dev.serial_impl = &serial_vtable;
	dev.port = port;
	chr::serial_init(dev);

	arch::install_irq(&dev.irq[0], IRQ3, &serial_irq, dev);
	arch::install_irq(&dev.irq[1], IRQ4, &serial_irq, dev);

	serial_outb(dev, IER,    0x00);   // Disable interrupts
	serial_outb(dev, LCR,    0x80);   // Enable divisor mode
	serial_outb(dev, DL_LSB, 0x01);   // Div Low:  01 Set the port to 115200 baud
	serial_outb(dev, DL_MSB, 0x00);   // Div High: 00
	serial_outb(dev, LCR,    0x03);   // Disable divisor mode, set parity
	serial_outb(dev, FCR,    0xC7);   // Enable FIFO and clear
	serial_outb(dev, MCR,    0x0B);   // Enable OUT1 & OUT2
	serial_outb(dev, IER,    ERBFI);  // Enable read interrupt

	arch::irq_ack(IRQ3);
	arch::irq_ack(IRQ4);
};

const serial_vtable = chr::serial_iface {
	write = &serial_write,
	...
};

fn serial_inb(dev: *pcserial, reg: u16) u8 = {
	return x86_64::inb(dev.port + reg);
};

fn serial_outb(dev: *pcserial, reg: u16, val: u8) void = {
	x86_64::outb(dev.port + reg, val);
};

fn serial_ready(dev: *pcserial) bool = {
	return (serial_inb(dev, LSR) & THRE) != 0;
};

fn serial_putc(dev: *pcserial, val: u8) void = {
	if (!serial_ready(dev)) {
		serial_outb(dev, IER, ERBFI | ETBEI);

		let wq = sched::wq_link { ... };
		for (!serial_ready(dev)) {
			sched::wait(&dev.wq, &wq);
		};

		serial_outb(dev, IER, ERBFI);
	};

	serial_outb(dev, THR, val);
};

fn serial_write(dev: *chr::serialdev, buf: const []u8) (size | error) = {
	let dev = dev: *pcserial;
	for (let i = 0z; i < len(buf); i += 1) {
		if (buf[i] == '\n') {
			serial_putc(dev, '\r');
		};
		serial_putc(dev, buf[i]);
	};
	return len(buf);
};

fn serial_read(dev: *pcserial) void = {
	for (serial_inb(dev, LSR) & RBF == RBF) {
		const ch = serial_inb(dev, RBR);
		switch (ch) {
		case '\x7f' =>	// Backspace
			serial_write(dev, ['\b', ' '])!;
			chr::serial_putc(dev, '\b');
		case =>
			chr::serial_putc(dev, ch);
		};
	};
};

fn serial_irq(irq: u8, user: nullable *opaque) void = {
	const dev = user: *pcserial;
	defer arch::irq_ack(irq);

	const iir = serial_inb(dev, IIR);
	if (iir & (1 << 2) != 0) {
		serial_read(dev);
	};
	if (iir & (1 << 1) != 0) {
		sched::wake(&dev.wq);
	};
};
