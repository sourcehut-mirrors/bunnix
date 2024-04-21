use arch::main;		// link
use log;

export fn main() void = {
	log::println("Hello from the kernel!");

	abort(); // TODO
};
