// Misc. assembly routines

export fn _lgdt(gdt: *opaque) void;
export fn ltr(tss: u16) void;
export fn _lidt(idt: *opaque) void;
export fn lseg(seg: u16) void;
export fn invlpg(addr: uintptr) void;
export fn outb(port: u16, val: u8) void;
export fn inb(port: u16) u8;
export fn outw(port: u16, val: u16) void;
export fn inw(port: u16) u16;
export fn outl(port: u16, val: u32) void;
export fn inl(port: u16) u32;
export fn cli() void;
export fn sti() void;
export fn swapgs() void;
