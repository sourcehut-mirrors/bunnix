use arch;
use errors::{error, errno};
use mman;
use sched;

export fn fork() (int | error) = {
	const parent = current();
	const ptask = parent.tasks[0]; // TODO: threads

	const child = new_proc(parent.root)?;
	const ctask = sched::newtask(child)?;
	mman::fork(&parent.vmm, &child.vmm)?;

	ctask.ctx = ptask.ctx;
	arch::context_set_rval(&ctask.ctx, 0, 0);
	return child.pid;
};
