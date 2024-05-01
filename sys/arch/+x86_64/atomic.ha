// Atomically adds a value to a variable and returns the new value.
export fn fetch_add(var: *u64, val: u64) u64;

// Memory barrier.
export fn barrier() void;
