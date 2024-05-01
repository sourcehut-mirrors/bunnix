use arch;
use errors::{error, errno};
use mman;
use sched;
use io;

export fn fork() (int | error) = {
	const parent = current();
	const ptask = parent.tasks[0]; // TODO: threads

	const child = new_proc(parent.root)?;
	const ctask = sched::newtask(&child.vmm, child)?;
	append(child.tasks, ctask);
	mman::fork(&parent.vmm, &child.vmm)?;

	child.fds = alloc([null...], len(parent.fds));
	for (let i = 0z; i < len(parent.fds); i += 1) {
		match (parent.fds[i]) {
		case let f: *io::file =>
			child.fds[i] = f;
			io::ref(f);
		case null => void;
		};
	};

	// Prepare child to return from syscall
	ctask.ctx = ptask.ctx;
	arch::context_set_rval(&ctask.ctx, 0, 0);
	arch::set_restore_point(&ctask.restore, &arch::sysret: uintptr);

	// Return to parent
	return child.pid;
};
