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
	fds: []filedesc,
	creds: creds,
	sig: sigproc,
	status: int,
	wq: sched::wq_head,

	// TODO: Multithreading
	tasks: []*sched::task,
};

// Creates a new process.
export fn new_proc(root: *fs::vfs, parent: nullable *proc) (*proc | error) = {
	static let nextpid: int = 1;
	assert(nextpid + 1 > nextpid); // TODO
	defer nextpid += 1;

	let creds = creds { ... };
	match (parent) {
	case let proc: *proc =>
		creds = proc.creds;
		creds.ppid = creds.pid;
	case null => void;
	};
	creds.pid = nextpid;

	let proc = alloc(proc {
		root = root,
		creds = creds,
		...
	});
	mman::vmm_init(&proc.vmm)?;

	append(procs, proc);
	return proc;
};

// Returns the currently active process.
export fn current() *proc = {
	const current = sched::current() as *sched::task;
	return current.user: *proc;
};

// Exits the calling process.
export fn exit(status: int) never = {
	const proc = current();
	if (proc.creds.pid == 1) {
		arch::panic("init exited", &proc.tasks[0].ctx);
	};

	proc.status = status << 8;

	for (let t .. proc.tasks) {
		sched::task_finish(t);
	};
	free(proc.tasks);

	sched::wake(&proc.wq);

	sched::schedule();
	abort(); // unreachable
};
