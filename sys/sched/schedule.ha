use arch;
use mman;

// Switches to the next available task.
export fn schedule() void = {
	match (current()) {
	case let prev: *task =>
		if (arch::save(&prev.restore)) {
			// Return from context switch
			return;
		};
	case null =>
		// Scheduler invoked during system initialization; there are no
		// tasks to wake up so just return here.
		return;
	};

	const next = match (task_next()) {
	case let t: *task =>
		yield t;
	case null =>
		abort(); // TODO: idle
	};

	switch_task(next);
};

// Switches to the given task.
fn switch_task(task: *task) void = {
	let cpu = arch::getcpu();
	cpu.task = &task.ctx;

	mman::vmm_map(task.vmm);

	const kstack = &(&task.ctx: *[*]arch::context)[1];
	arch::set_kernel_stack(kstack);

	arch::restore(&task.restore);
};
