use mb;

const @symbol("__init_array_start") init_start: [*]*fn() void;
const @symbol("__init_array_end") init_end: [*]*fn() void;
@symbol("bmain") fn bmain(mb: *mb::multiboot, mb_magic: u32, esp: *opaque) never;

export fn start(mb: *mb::multiboot, mb_magic: u32, esp: *opaque) never = {
	const ninit = (&init_end: uintptr - &init_start: uintptr): size
		/ size(*fn() void);
	for (let i = 0z; i < ninit; i += 1) {
		init_start[i]();
	};

	bmain(mb, mb_magic, esp);
};
