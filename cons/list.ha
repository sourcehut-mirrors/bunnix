def CONS_STATIC: size = 32;

let static_cons_buf: [CONS_STATIC]*console = [null: *console...];
let static_cons: []*console = [];

// Registers a console with the static list of consoles.
export fn register(cons: *console) void = {
	if (len(static_cons) == 0) {
		static_cons = static_cons_buf[..0];
	};
	if (len(static_cons) >= CONS_STATIC) {
		return;
	};
	static append(static_cons, cons);
};

// Initializes a [[multi_console]] that writes to all registered consoles.
export fn all(cons: *multi_console) void = {
	multi_init(cons, static_cons...);
};
