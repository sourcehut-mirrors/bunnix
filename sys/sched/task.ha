use arch;
use errors::{error, errno};
use mman;

def KSTACK_SIZE: size = 65536;
def OVERHEAD = size(arch::context) + size(taskstate);

// Stack alignment requirements
static assert((KSTACK_SIZE - OVERHEAD) % 8 == 0);

export type kstack = [KSTACK_SIZE - OVERHEAD]u8;

export type task_state = enum {
	RUNNING,
	BLOCKED,
};

export type task = struct {
	kstack: kstack,
	ctx: arch::context,
	taskstate,
};

export type taskstate = struct {
	user: nullable *opaque,
	state: task_state,
};

// Allocates a new schedulable task.
export fn newtask(user: *opaque) (*task | error) = {
	const base = mman::mmap(
		&mman::kernel, 0, 0,
		size(task),
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON)?;
	let task = base: *task;
	task.user = user;
	task.state = task_state::RUNNING;
	arch_init(&task.ctx);
	return task;
};

fn task_fromctx(ctx: *arch::context) *task = {
	return (ctx: uintptr - size(kstack): uintptr): *task;
};

// Returns the currently active task.
export fn current() *task = {
	const cpu = arch::getcpu();
	return task_fromctx(cpu.task: *arch::context);
};
