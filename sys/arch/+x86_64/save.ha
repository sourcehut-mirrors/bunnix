// Saves the current processor execution context. Acts like setjmp: calling save
// initially returns false, and calling restore will cause this function to
// return again with true.
export fn save(ctx: *restore_point) i64;

// Restores a processor context saved earlier with [[save]].
export fn restore(ctx: *restore_point, rval: i64) never;

// Sets the instruction pointer register in a [[restore_point]].
export fn set_restore_point(rp: *restore_point, ip: uintptr) void = {
	rp.rip = ip;
};
