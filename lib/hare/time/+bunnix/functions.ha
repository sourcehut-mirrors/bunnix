// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use rt;

// Converts a [[duration]] to an [[rt::timespec]]. This function is
// non-portable.
export fn duration_to_timespec(d: duration) rt::timespec = rt::timespec {
	tv_sec = d / SECOND,
	tv_nsec = d % SECOND,
};

// Converts an [[instant]] to an [[rt::timespec]]. This function is
// non-portable.
export fn instant_to_timespec(t: instant) rt::timespec = rt::timespec {
	tv_sec = t.sec,
	tv_nsec = t.nsec,
};

// Converts a [[rt::timespec]] to an [[instant]]. This function is non-portable.
export fn timespec_to_instant(ts: rt::timespec) instant = instant {
	sec = ts.tv_sec,
	nsec = ts.tv_nsec,
};

// Yields the process to the kernel and returns after the requested duration.
export fn sleep(d: duration) void = {
	let req = duration_to_timespec(d);

	// TODO: Handle EINTR
	rt::nanosleep(&req)!;
};

// An enumeration of clocks available on this system. Different clocks represent
// times from different epochs, and have different characteristics with regards
// to leap seconds, NTP adjustments, and so on. All systems provide the REALTIME
// and MONOTONIC clocks at least; use of other clocks is not guaranteed to be
// portable.
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
	abort(); // TODO Bunnix
};
