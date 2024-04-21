// Reads the current page table from CR3.
export fn rdcr3() uintptr;

// Writes an address to the CR3 register (setting the current page table).
export fn wrcr3(addr: uintptr) void;

// Invalidates an address in the page table.
export fn invlpg(addr: uintptr) void;

export fn outb(port: u16, val: u8) void;
export fn inb(port: u16) u8;
export fn outw(port: u16, val: u16) void;
export fn inw(port: u16) u16;
export fn outl(port: u16, val: u32) void;
export fn inl(port: u16) u32;
