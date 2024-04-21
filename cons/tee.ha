export type multi_console = struct {
	cons: console,
	consoles: []*console,
};

// Initializes a console that writes to several other consoles.
export fn multi_init(
	cons: *multi_console,
	consoles: *console...
) void = {
	*cons = multi_console {
		cons = console {
			write = &multi_write,
			clear = &multi_clear,
		},
		consoles = consoles,
	};
};

fn multi_write(cons: *console, buf: []u8) size = {
	let cons = cons: *multi_console;
	assert(cons.cons.write == &multi_write);
	for (let i = 0z; i < len(cons.consoles); i += 1) {
		write(cons.consoles[i], buf);
	};
	return len(buf);
};

fn multi_clear(cons: *console) void = {
	let cons = cons: *multi_console;
	assert(cons.cons.clear == &multi_clear);
	for (let i = 0z; i < len(cons.consoles); i += 1) {
		clear(cons.consoles[i]);
	};
};
