@symbol("main") fn main() void;

export fn start() void = {
	do_init();
	main();
	do_fini();

	abort(); // TODO: exit
};
