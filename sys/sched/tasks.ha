use arch;

let head: nullable *task = null;

fn task_insert(task: *task) void = {
	task.next = head;
	head = task;
};

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
