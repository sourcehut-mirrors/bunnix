use arch;
use mman;

let head: nullable *task = null;

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

fn task_next() nullable *task = {
	const prev = current() as *task;
	let next: nullable *task = prev.next;
	for (next != prev) {
		if (next == null) {
			next = head;
		};
		const cand = next: *task;
		if (cand.state == task_state::RUNNING) {
			return cand;
		};
		next = cand.next;
	};
	if (prev.state == task_state::RUNNING) {
		return prev;
	};
	return null;
};

// Adds a task to the scheduler.
export fn task_link(new: *task) void = {
	new.prev = null;
	new.next = head;
	if (head == null) {
		head = new;
	} else {
		(head: *task).prev = new;
		head = new;
	};
};

// Removes a task from the scheduler and frees state associated with it.
export fn task_unlink(t: *task) void = {
	match (t.prev) {
	case let prev: *task =>
		prev.next = t.next;
	case null =>
		match (t.next) {
		case null => void;
		case let task: *task =>
			head = task;
		};
	};
	match (t.next) {
	case let next: *task =>
		next.prev = t.prev;
	case null => void;
	};

	mman::munmap(&mman::kernel, t: uintptr, size(task))!;

	// TODO: deal with unlinking current task properly
};
