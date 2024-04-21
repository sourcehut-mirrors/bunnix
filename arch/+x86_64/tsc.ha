type tsc_interval = struct {
	start: u64,
	stop: u64,
};

fn measuretsc(out: *tsc_interval) void;

// TSC rate in Hz.
export let tsc_rate: u64 = 0;

// Reads the current TSC value.
export fn rdtsc() u64;

// Measures the TSC clock speed.
export fn init_tsc() void = {
	let timings = tsc_interval { ... };
	measuretsc(&timings);
	tsc_rate = (timings.stop - timings.start) * 100;
};
