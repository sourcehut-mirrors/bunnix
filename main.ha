// Linkage
use arch::main;

export fn main() void = {
	writestr("Hello from the kernel!\n");
	abort(); // TODO
};
