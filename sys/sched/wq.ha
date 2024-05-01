use arch;

export type wq_func = fn(link: *wq_link) void;

export type wq_link = struct {
	next: nullable *wq_link,
	user: nullable *opaque,
	func: nullable *wq_func,
};

export type wq_head = struct {
	head: nullable *wq_link,
};

// Waits until the given waitqueue is signalled.
export fn wait(
	head: *wq_head,
	link: *wq_link,
	func: nullable *wq_func = null,
	user: nullable *opaque = null,
) void = {
	const task = match (current()) {
	case null =>
		// Attempted to wait while scheduler was not active
		arch::pause();
		return;
	case let t: *task =>
		yield t;
	};

	if (func == null) {
		func = &default_wake;
		user = task;
	};

	task.state = task_state::WAIT;
	link.func = func;
	link.user = user;

	link.next = head.head;
	head.head = link;
	schedule();
};

// Wakes all threads on this wait queue.
export fn wake(head: *wq_head) void = {
	let next: nullable *wq_link = head.head;
	for (let cur = next; cur != null; cur = next) {
		let cur = cur: *wq_link;
		next = cur.next;
		cur.next = null;
		const func = cur.func as *wq_func;
		func(cur);
	};
	head.head = null;
};

fn default_wake(link: *wq_link) void = {
	const task = link.user: *task;
	assert(task.state == task_state::WAIT);
	task.state = task_state::RUNNING;
};
