use arch::x86_64;

def PIT_CH0: u16 = 0x40;
def PIT_CH1: u16 = 0x41;
def PIT_CH2: u16 = 0x42;
def PIT_CMD: u16 = 0x43;

def PIT_SCALE: u64 = 1193180;
def PIT_SET: u8 = 0x34;
def PIT_MASK: u8 = 0xFF;

// The IRQ number assigned to the PIT.
export def PIT_IRQ: u8 = 0;

// Sets the PIT interval to the given phase in Hz.
export fn pit_setphase(hz: u64) void = {
	assert(hz != 0);
	const divisor = PIT_SCALE / hz;
	x86_64::outb(PIT_CMD, PIT_SET);
	x86_64::outb(PIT_CH0, (divisor & PIT_MASK): u8);
	x86_64::outb(PIT_CH0, ((divisor >> 8) & PIT_MASK): u8);
};
