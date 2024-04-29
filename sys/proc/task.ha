use arch;
use errors::{error, errno};
use mman;

def STACK_SIZE: size = 65536;
def OVERHEAD = size(arch::context) + size(taskstate);

// Stack alignment requirements
static assert((STACK_SIZE - OVERHEAD) % 8 == 0);

export type kstack = [STACK_SIZE - OVERHEAD]u8;

export type task = struct {
	kstack: kstack,
	state: arch::context,
	taskstate,
};

export type taskstate = struct {
	proc: nullable *proc,
};

// Allocates a new task.
fn newtask() (*task | error) = {
	const base = mman::mmap(
		&mman::kernel, 0, 0,
		size(task),
		mman::prot::READ | mman::prot::WRITE,
		mman::flag::ANON)?;
	let task = base: *task;
	arch_init(&task.state);
	return task;
};

fn task_fromctx(ctx: *arch::context) *task = {
	return (ctx: uintptr - size(kstack): uintptr): *task;
};
