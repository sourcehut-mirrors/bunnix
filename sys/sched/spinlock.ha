use arch;

// A spinlock object.
export type spinlock = struct {
	ticket: u64,
	turn: u64,
};

// Aquires a spinlock.
export fn spinlock_acquire(lock: *spinlock) void = {
	const ticket = arch::fetch_add(&lock.ticket, 1);
	for (lock.turn != ticket) {
		arch::pause();
	};
	arch::barrier();
};

// Releases a spinlock.
export fn spinlock_release(lock: *spinlock) void = {
	arch::fetch_add(&lock.turn, 1);
};
