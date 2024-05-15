use arch;

// An enumeration of clocks available on this system.
export type clock = enum {
	// The current wall-clock time. This may jump forwards or backwards in
	// time to account for leap seconds, NTP adjustments, etc.
	REALTIME = 0,
	// The current monotonic time. This clock measures from some undefined
	// epoch and is not affected by leap seconds, NTP adjustments, and
	// changes to the system time: it always increases by one second per
	// second.
	MONOTONIC = 1,

	MAX = MONOTONIC,
};

let bootunix: u64 = 0;
let bootticks: u64 = 0;

// Sets the Unix time at boot.
export fn set_basis(unix: u64, ticks: u64) void = {
	bootunix = unix;
	bootticks = ticks;
};

// Returns the current time for a given clock.
export fn now(clock: clock) instant = {
	let now = arch::gettime();
	const rate = arch::getrate();

	let sec = 0u64;
	let remain = 0u64;
	switch (clock) {
	case clock::REALTIME =>
		now -= bootticks;
		sec = now / rate;
		remain = now % rate;
		sec += bootunix;
	case clock::MONOTONIC =>
		sec = now / rate;
		remain = now % rate;
	};

	const nsec = 10e11 / rate * remain / 10e2;
	return instant {
		sec = sec: i64,
		nsec = nsec: i64,
	};
};

// Blocks and returns after the given duration. For the preemptable version, see
// sched::sleep.
export fn sleep(d: duration) void = {
	const deadline = add(now(clock::MONOTONIC), d);
	for (true) {
		const now = now(clock::MONOTONIC);
		if (compare(now, deadline) == 1) {
			break;
		};
		arch::pause();
	};
};
