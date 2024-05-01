use arch;
use mman;

// Switches to the next available task. Returns true if we context switched as a
// result of the call.
export fn schedule() bool = {
	const prev = match (current()) {
	case let prev: *task =>
		if (arch::save(&prev.restore)) {
			// Return from context switch
			return true;
		};
		yield prev;
	case null =>
		// Scheduler invoked during system initialization; there are no
		// tasks to wake up so just return here.
		return false;
	};

	const next = match (task_next()) {
	case let t: *task =>
		yield t;
	case null =>
		abort(); // TODO: idle
	};

	if (next == prev) {
		return false;
	};

	switch_task(next);
};

// Switches to the given task.
fn switch_task(task: *task) never = {
	let cpu = arch::getcpu();
	cpu.task = &task.ctx;

	mman::vmm_map(task.vmm);

	const kstack = &(&task.ctx: *[*]arch::context)[1];
	arch::set_kernel_stack(kstack);

	arch::restore(&task.restore);
};
