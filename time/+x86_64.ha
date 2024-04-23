// License: MPL-2.0
// (c) 2021 Drew DeVault <sir@cmpwn.com>
// (c) 2021 Ember Sawady <ecs@d2evs.net>
// (c) 2021 Mykyta Holubakha <hilobakho@gmail.com>
use arch;

// Reads the current TSC value.
export fn rdtsc() u64;

// An enumeration of clocks available on this system.
// TODO: Implement more clocks
export type clock = enum {
	// The current wall-clock time. This may jump forwards or backwards in
	// time to account for leap seconds, NTP adjustments, etc.
	REALTIME = 0,
	// The current monotonic time. This clock measures from some undefined
	// epoch and is not affected by leap seconds, NTP adjustments, and
	// changes to the system time: it always increases by one second per
	// second.
	MONOTONIC = 1,
};

// Returns the current time for a given clock.
export fn now(clock: clock) instant = {
	assert(clock == clock::MONOTONIC);

	const now = rdtsc();
	const sec = now / arch::tsc_rate;
	const remain = now % arch::tsc_rate;
	const nsec = 10e11 / arch::tsc_rate * remain / 10e2;
	return instant {
		sec = sec: i64,
		nsec = nsec: i64,
	};
};

// Returns after the requested duration.
export fn sleep(d: duration) void = {
	const deadline = add(now(clock::MONOTONIC), d);
	for (true) {
		const now = now(clock::MONOTONIC);
		if (compare(now, deadline) == 1) {
			break;
		};
	};
};
