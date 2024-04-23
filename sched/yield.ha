use time;

// Yields the CPU for the current task.
export fn yieldtask() void = {
	// TODO
	time::sleep(5 * time::MILLISECOND);
};
