use arch;

export type tickfunc = fn(ticks: u64, nullable *opaque) void;

export type tick_link = struct {
	next: nullable *tick_link,
	func: nullable *tickfunc,
	user: nullable *opaque,
};

let tick_head: nullable *tick_link = null;

// Registers a callback to be regularly called on timer interrupts.
// Yes this is a hack
export fn ontick(
	link: *tick_link,
	func: *tickfunc,
	user: nullable *opaque = null,
) void = {
	link.func = func;
	link.user = user;
	link.next = tick_head;
	tick_head = link;
};

export type timer = struct {
	wq: wq_link,
	deadline: u64,
	task: nullable *task,
};

let timers = wq_head { ... };

// Sleeps until the given deadline.
export fn sleep(timer: *timer, until: u64) void = {
	timer.task = current() as *task;
	timer.deadline = until;
	wait(&timers, &timer.wq, &timer_wake);
};

// Processes all pending timers.
export fn timer_process() void = {
	const now = arch::gettime();
	for (let link = tick_head; link != null; link = (link: *tick_link).next) {
		const link = link: *tick_link;
		(link.func as *tickfunc)(now, link.user);
	};

	signal(&timers, &now);
};

fn timer_wake(link: *wq_link, user: nullable *opaque) void = {
	const now = user: *u64;
	const timer = link: *timer;
	if (*now >= timer.deadline) {
		const task = timer.task as *task;
		task_activate(task);
		wq_unlink(link);
	};
};
