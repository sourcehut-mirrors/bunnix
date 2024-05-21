export fn write(buf: const []u8) void = {
	serial_write(buf);
	vga_write(buf);
};

export fn writestr(s: str) void = write(*(&s: *[]u8));
