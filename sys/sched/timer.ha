use arch;

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
	signal(&timers, &now);
};

fn timer_wake(link: *wq_link, user: nullable *opaque) void = {
	const now = user: *u64;
	const timer = link: *timer;
	if (*now >= timer.deadline) {
		const task = timer.task as *task;
		task_activate(task);
		wq_unlink(&timers, link);
	};
};
