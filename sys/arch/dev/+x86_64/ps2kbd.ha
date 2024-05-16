use arch;
use arch::x86_64;
use dev::chr;

def PS2_IRQ: u8 = 1;
def PS2_DATA = 0x60;
def PS2_STATUS = 0x64;
def PS2_CMD = 0x64;

// TODO: Generic PS/2 driver (mouse!)
export fn ps2_init() void = {
	static let ps2_irqhandler = arch::irq_handler { ... };
	arch::install_irq(&ps2_irqhandler, PS2_IRQ, &ps2_irq);
	chr::kbd_init(&ps2_kbd);
};

fn ps2_irq(user: nullable *opaque) void = {
	let scancode = x86_64::inb(PS2_DATA);

	const mask = 1u8 << 7;
	const state = if (scancode & mask == 0) {
		yield chr::key_state::PRESSED;
	} else {
		yield chr::key_state::RELEASED;
	};
	scancode = (scancode & ~mask) + 8;

	chr::kbd_keyproc(&ps2_kbd, scancode, state);
};

const kbd_impl = chr::kbd_iface {
	set_led = &kbd_set_led,
};

const ps2_kbd = chr::kbd {
	kbd_iface = &kbd_impl,
	...
};

fn kbd_set_led(kbd: *chr::kbd, led: chr::kbd_led) void = {
	abort(); // TODO
};
