// Reads the current page table from CR3.
export fn rdcr3() uintptr;

// Writes an address to the CR3 register (setting the current page table).
export fn wrcr3(addr: uintptr) void;

// Invalidates an address in the page table.
export fn invlpg(addr: uintptr) void;
