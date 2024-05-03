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
	creds: creds,

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

// Installs the given [[file]] in the process's file descriptor table, returning
// the assigned file descriptor number.
export fn installfd(proc: *proc, file: *io::file) int = {
	for (let i = 0z; i < len(proc.fds); i += 1) {
		if (proc.fds[i] == null) {
			proc.fds[i] = file;
			return i: int;
		};
	};
	append(proc.fds, file);
	return (len(proc.fds) - 1): int;
};

// Returns the currently active process.
export fn current() *proc = {
	const current = sched::current() as *sched::task;
	return current.user: *proc;
};
