use arch;

export type wq_func = fn(link: *wq_link, user: nullable *opaque) void;

export type wq_link = struct {
	next: nullable *wq_link,
	prev: nullable *nullable *wq_link,
	user: nullable *opaque,
	func: nullable *wq_func,
};

export type wq_head = struct {
	head: nullable *wq_link,
};

// Waits until the given waitqueue is signalled. Returns true if we switched
// contexts during the wait.
export fn wait(
	head: *wq_head,
	link: *wq_link,
	func: nullable *wq_func = null,
	user: nullable *opaque = null,
) bool = {
	assert(link.prev == null && link.next == null,
		"sched::wait race on wq_link");
	const task = match (current()) {
	case null =>
		// Attempted to wait while scheduler was not active, pause and
		// return immediately (busy loop)
		arch::pause();
		return false;
	case let t: *task =>
		yield t;
	};

	if (func == null) {
		func = &default_wake;
		user = task;
	};

	task_block(task);

	link.func = func;
	link.user = user;

	match (head.head) {
	case null =>
		head.head = link;
		link.prev = &head.head;
	case let next: *wq_link =>
		next.prev = &link.next;
		link.next = next;
		link.prev = &head.head;
		head.head = link;
	};

	return schedule();
};

// Wakes all threads on this wait queue.
export fn wake(head: *wq_head, user: nullable *opaque = null) void = {
	let next: nullable *wq_link = head.head;
	for (let cur = next; cur != null; cur = next) {
		let cur = cur: *wq_link;
		next = cur.next;
		cur.next = null;
		cur.prev = null;
		const func = cur.func as *wq_func;
		func(cur, user);
	};
	head.head = null;
};

// Signals all threads on this wait queue without removing them from the wait
// queue.
export fn signal(head: *wq_head, user: nullable *opaque = null) void = {
	let next: nullable *wq_link = head.head;
	for (let cur = next; cur != null; cur = next) {
		let cur = cur: *wq_link;
		next = cur.next;
		const func = cur.func as *wq_func;
		func(cur, user);
	};
};

// Unlinks this wait queue entry from the wait list, without waking or signaling
// it.
export fn wq_unlink(link: *wq_link) void = {
	// Don't double unlink wqs
	if (link.prev == null) {
		assert(link.next == null);
		return;
	};

	const prev = link.prev as *nullable *wq_link;
	*prev = link.next;

	match (link.next) {
	case let next: *wq_link =>
		next.prev = prev;
	case null => void;
	};

	link.prev = null;
	link.next = null;
};

fn default_wake(link: *wq_link, user: nullable *opaque) void = {
	const task = link.user: *task;
	task_activate(task);
};
