use arch;
use errors::{error, errno};
use mman;

def STACK_SIZE: size = 65536;
def OVERHEAD = size(arch::context);

// Stack alignment requirements
static assert((STACK_SIZE - OVERHEAD) % 8 == 0);

export type task = struct {
	kstack: [STACK_SIZE - OVERHEAD]u8,
	state: arch::context,
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
