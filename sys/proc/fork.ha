use arch;
use errors::{error, errno};
use mman;

export fn fork() (int | error) = {
	const parent = current();
	const ptask = parent.tasks[0]; // TODO: threads

	const child = new_proc(parent.root)?;
	const ctask = newtask(child)?;
	mman::fork(&parent.vmm, &child.vmm)?;

	ctask.state = ptask.state;
	arch::context_set_rval(&ctask.state, 0);
	return child.pid;
};
