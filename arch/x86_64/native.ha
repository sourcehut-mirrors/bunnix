// Reads the current page table from CR3.
export fn rdcr3() uintptr;

// Writes an address to the CR3 register (setting the current page table).
export fn wrcr3(addr: uintptr) void;

// Invalidates an address in the page table.
export fn invlpg(addr: uintptr) void;

// Writes the given 8-bit value to the given port.
export fn outb(port: u16, val: u8) void;
