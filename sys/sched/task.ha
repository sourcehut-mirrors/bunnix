use arch;
use errors::{error, errno};
use mman;

def KSTACK_SIZE: size = 65536;

// Stack alignment requirements
static assert((KSTACK_SIZE) % 8 == 0);

export type kstack = [KSTACK_SIZE]u8;

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
	vmm: *mman::vmm,
	state: task_state,
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
	// TODO: Start in an undefined state until the caller finishes preparing
	// it? Necessary before we implement kernel preemption
	task.state = task_state::RUNNING;
	task.vmm = vmm;
	arch_init(&task.ctx);
	task_link(task);
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
