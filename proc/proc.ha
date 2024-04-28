use arch;
use errors::{error, errno};
use mman;
use fs;
use io;

// A process in userspace.
export type proc = struct {
	vmm: mman::vmm,
	root: *fs::vfs,
	fds: []nullable *io::file,

	// TODO: Multithreading
	task: *task,
};

// Creates a new process.
export fn new_proc(root: *fs::vfs) (*proc | error) = {
	let proc = alloc(proc {
		root = root,
		task = newtask()?,
		...
	});
	proc.task.proc = proc;
	return proc;
};

// Appends a file descriptor to this process's file table.
export fn appendfd(proc: *proc, file: *io::file) int = {
	append(proc.fds, file);
	return (len(proc.fds) - 1): int;
};

// Returns the currently active process.
export fn current() *proc = {
	const cpu = arch::getcpu();
	const task = task_fromctx(cpu.task: *arch::context);
	return task.proc as *proc;
};
