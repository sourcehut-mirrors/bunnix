use arch;
use rt;

@symbol("main") fn kmain() never;

export fn main() never = {
	// TODO: Target-specific initialization

	rt::do_init();

	kmain();
};
