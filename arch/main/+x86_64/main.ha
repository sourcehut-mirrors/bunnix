@symbol("main") fn kmain() never;

export fn main() never = {
	// TODO: Target-specific initialization

	kmain();
};
