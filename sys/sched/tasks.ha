use arch;
use mman;

let head: nullable *task = null;

fn task_next() nullable *task = {
	const prev = current();
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
