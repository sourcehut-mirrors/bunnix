use arch;
use errors::{error, errno};
use mman;

def KSTACK_SIZE: size = 65536;

// Stack alignment requirements
static assert((KSTACK_SIZE) % 8 == 0);

export type kstack = [KSTACK_SIZE]u8;

export type task_state = enum {
	STARTUP,
	RUNNING,
	WAIT,
};

export type task = struct {
	kstack: kstack,
	ctx: arch::context,
	taskstate,
};

export type taskstate = struct {
	vmm: *mman::vmm,
	state: task_state,
	restore: arch::restore_point,
	next: nullable *task,
	prev: nullable *task,
	user: nullable *opaque,
};

// Allocates a new schedulable task.
export fn newtask(vmm: *mman::vmm, user: *opaque) (*task | error) = {
	const base = mman::mmap(
		&mman::kernel, 0, 0,
		size(task),
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON)?;
	let task = base: *task;
	task.user = user;
	task.state = task_state::STARTUP;
	task.vmm = vmm;
	arch_init(&task.ctx);
	return task;
};

// Configures a task as running and adds it to the scheduler.
export fn task_activate(task: *task) void = {
	assert(task.state != task_state::RUNNING);
	task.state = task_state::RUNNING;
	task_link(task);
};

// Configures a task as blocked and removes it from the scheduler.
export fn task_block(task: *task) void = {
	task.state = task_state::WAIT;
	task_unlink(task);
};

// Frees resouces associated with a task.
export fn task_finish(which: *task) void = {
	if (which.state == task_state::RUNNING) {
		task_unlink(which);
	};

	// TODO: ensure this task is not active

	mman::munmap(&mman::kernel, which: uintptr, size(task))!;
};

fn task_fromctx(ctx: *arch::context) *task = {
	return (ctx: uintptr - size(kstack): uintptr): *task;
};

// Returns the currently active task. Only returns null during system startup.
export fn current() nullable *task = {
	const cpu = arch::getcpu();
	match (cpu.task) {
	case let ctx: *arch::context =>
		if (ctx == idle) {
			return null;
		};
		return task_fromctx(ctx);
	case null =>
		return null;
	};
};
