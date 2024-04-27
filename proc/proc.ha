use arch;
use errors::{error, errno};
use mman;

// A process in userspace.
export type proc = struct {
	vmm: mman::vmm,
	state: arch::context,
};

// Creates a new process.
export fn new_proc() (*proc | error) = {
	let proc = alloc(proc {
		...
	});
	mman::vmm_init(&proc.vmm)?;
	return proc;
};
