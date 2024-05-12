use os;
use io;
use fmt;

export type key_state = enum uint {
	PRESSED,
	RELEASED,
};

export type key_evdata = struct {
	scancode: u32,
	state: key_state,
};

export fn main() void = {
	const kbd = os::open("/dev/kbd")!;
	for (true) {
		let buf: [size(key_evdata)]u8 = [0...];
		io::read(kbd, buf)!;
		let ev = &buf[0]: *key_evdata;
		fmt::printfln("{}: {}",
			ev.scancode,
			switch (ev.state) {
			case key_state::PRESSED =>
				yield "pressed";
			case key_state::RELEASED =>
				yield "released";
			})!;
	};
};
