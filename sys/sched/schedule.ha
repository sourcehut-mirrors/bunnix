use arch;
use mman;

// Linked list of schedulable tasks
let head: nullable *task = null;

// Forward declaration
fn proc::resume_signal(task: *task) bool;

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
		if (!is_idle()) {
			// Scheduler invoked during system initialization; there
			// are no tasks to wake up so just return here.
			return false;
		};
		yield null;
	};

	for (true) {
		const next = match (task_next()) {
		case let t: *task =>
			yield t;
		case null =>
			switch_idle();
		};

		// Ensure that the task is linked and runnable
		assert(next.next != null || next.prev != null);

		if (next == prev) {
			return false;
		};

		if (!proc::resume_signal(next)) {
			continue; // Select another task
		};
		switch_task(next);
	};
};

// Switches to the given task.
fn switch_task(task: *task) never = {
	let cpu = arch::getcpu();
	cpu.task = &task.ctx;

	const kstack = &(&task.ctx: *[*]arch::context)[1];
	arch::set_kernel_stack(kstack);
	mman::vmm_map(task.vmm);

	arch::restore(&task.restore);
};

fn task_next() nullable *task = {
	match (current()) {
	case let t: *task =>
		match (t.next) {
		case let next: *task =>
			return next;
		case null =>
			return head;
		};
	case null =>
		// Return from idle, schedule head
		return head;
	};
};

// Adds a task to the scheduler.
export fn task_link(link: *task) void = {
	// Don't double link tasks
	assert(link.prev == null && link.next == null);

	match (head) {
	case null =>
		head = link;
		link.prev = &head;
	case let next: *task =>
		next.prev = &link.next;
		link.next = next;
		link.prev = &head;
		head = link;
	};
};

// Removes a task from the scheduler.
export fn task_unlink(link: *task) void = {
	// Don't double unlink tasks
	if (link.prev == null) {
		assert(link.next == null);
		return;
	};

	const prev = link.prev as *nullable *task;
	*prev = link.next;

	match (link.next) {
	case let next: *task =>
		next.prev = prev;
	case null => void;
	};

	link.prev = null;
	link.next = null;
};
