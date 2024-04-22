// Given a 32-bit device identifier, returns the bus.
export fn device_bus(device: u32) u8 = (device >> 16): u8;

// Given a 32-bit device identifier, returns the slot.
export fn device_slot(device: u32) u8 = (device >> 8): u8;

// Given a 32-bit device identifier, returns the function.
export fn device_func(device: u32) u8 = device: u8;

// Creates a 32-bit device identifier from a bus, slot, and function.
export fn device(bus: u8, slot: u8, func: u8) u32 =
	bus: u32 << 16 | slot: u32 << 8 | func: u32;
