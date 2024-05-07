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
	root: *io::inode,
	cwd: *io::inode,
	fds: []filedesc,
	creds: creds,
	sig: sigproc,

	status: int,
	exited: bool,
	wq: sched::wq_head,
	children: []*proc,

	// TODO: Multithreading
	tasks: []*sched::task,
};

// Creates a new process.
export fn new_proc(
	root: *io::inode,
	cwd: *io::inode,
	parent: nullable *proc,
) (*proc | error) = {
	static let nextpid: int = 1;
	assert(nextpid + 1 > nextpid); // TODO
	defer nextpid += 1;

	let creds = creds { ... };
	creds.pid = nextpid;

	io::inode_ref(root);
	io::inode_ref(cwd);

	let new_proc = alloc(proc {
		root = root,
		cwd = cwd,
		creds = creds,
		...
	});
	mman::vmm_init(&new_proc.vmm)?;

	match (parent) {
	case let proc: *proc =>
		new_proc.creds = proc.creds;
		new_proc.creds.pid = nextpid;
		new_proc.creds.ppid = proc.creds.pid;
		append(proc.children, new_proc);
	case null => void;
	};

	append(procs, new_proc);
	return new_proc;
};

// Returns the currently active process.
export fn current() *proc = {
	const current = sched::current() as *sched::task;
	return current.user: *proc;
};

// Returns a process by its pid.
export fn getproc(pid: int) (*proc | error) = {
	// TODO: Binary search
	for (let proc .. procs) {
		if (proc.creds.pid == pid) {
			return proc;
		};
	};
	return errno::CHILD;
};

fn cleanup(proc: *proc) void = {
	for (let t .. proc.tasks) {
		sched::task_block(t);
	};

	for (let fd .. proc.fds) {
		match (fd.file) {
		case let f: *io::file =>
			io::unref(f);
		case null => void;
		};
	};
	free(proc.fds);

	io::inode_unref(proc.root);
	io::inode_unref(proc.cwd);
};

// Exits the calling process.
export fn exit(status: int) never = {
	const proc = current();
	if (proc.creds.pid == 1) {
		arch::panic("init exited", &proc.tasks[0].ctx);
	};

	assert(!proc.exited);
	proc.status = (status & 0x7f) << 8;
	proc.exited = true;

	const parent = getproc(proc.creds.ppid)!;
	sched::wake(&parent.wq);

	cleanup(proc);

	sched::schedule();
	abort(); // unreachable
};

// Frees resources associated with this process.
export fn finish(proc: *proc) void = {
	assert(proc.creds.pid != 1);
	assert(proc.exited);

	for (let t .. proc.tasks) {
		sched::task_finish(t);
	};
	free(proc.tasks);

	const parent = getproc(proc.creds.ppid)!;
	for (let i = 0z; i < len(parent.children); i += 1) {
		if (parent.children[i] == proc) {
			delete(parent.children[i]);
			break;
		};
	};

	mman::vmm_finish(&proc.vmm);
	free(proc);
};
