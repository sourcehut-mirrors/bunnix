use arch;
use errors::{error, errno};
use fs;
use io;
use mman;
use sched;

let procs: []*proc = [];

// A process in userspace.
export type proc = struct {
	vmm: mman::vmm,
	root: *fs::vfs,
	fds: []nullable *io::file,
	pid: int,

	// TODO: Multithreading
	tasks: []*sched::task,
};

// Creates a new process.
export fn new_proc(root: *fs::vfs) (*proc | error) = {
	static let nextpid: int = 1;
	assert(nextpid + 1 > nextpid); // TODO
	defer nextpid += 1;

	let proc = alloc(proc {
		root = root,
		pid = nextpid,
		...
	});
	mman::vmm_init(&proc.vmm)?;

	append(procs, proc);
	return proc;
};

// Appends a file descriptor to this process's file table.
export fn appendfd(proc: *proc, file: *io::file) int = {
	append(proc.fds, file);
	return (len(proc.fds) - 1): int;
};

// Returns the currently active process.
export fn current() *proc = {
	const current = sched::current() as *sched::task;
	return current.user: *proc;
};
