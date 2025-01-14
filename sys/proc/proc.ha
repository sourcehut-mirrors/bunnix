use arch;
use errors::{error, errno};
use fs;
use io;
use mman;
use sched;
use strings;

let procs: []*proc = [];

// A process in userspace.
export type proc = struct {
	vmm: mman::vmm,
	root: *io::inode,
	cwd: *io::inode,
	fds: []filedesc,
	creds: creds,
	sig: sigproc,
	ctty: u64,
	args: []str,

	// XXX HACK
	cwd_str: str,

	status: int,
	exited: bool,
	wq: sched::wq_head,
	children: []*proc,

	// TODO: Multithreading
	tasks: []*sched::task,
};

// Returns the name of the active process.
export fn procname() str = {
	if (sched::current() == null) {
		return "<kernel>";
	};
	return current().args[0];
};

// Creates a new process.
export fn new_proc(
	root: *io::inode,
	cwd: *io::inode,
	cwd_str: str,
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
		cwd_str = strings::dup(cwd_str),
		creds = creds,
		...
	})!;
	mman::vmm_init(&new_proc.vmm)?;

	match (parent) {
	case let proc: *proc =>
		new_proc.creds = proc.creds;
		new_proc.creds.pid = nextpid;
		new_proc.creds.ppid = proc.creds.pid;
		new_proc.ctty = proc.ctty;
		append(proc.children, new_proc)!;
	case null => void;
	};

	append(procs, new_proc)!;
	return new_proc;
};

// Returns the currently active process.
export fn current() *proc = {
	const current = sched::current() as *sched::task;
	return current.user: *proc;
};

// Returns the controlling TTY device number for the current process.
export fn ctty() u64 = {
	return current().ctty;
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

	const nchild = len(proc.children);
	const init = procs[0];
	assert(init.creds.pid == 1);
	for (let child .. proc.children) {
		child.creds.ppid = 1;
		append(init.children, child)!;
	};
	free(proc.children);

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

	free(proc.cwd_str);
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
	if (!signal(parent, sig::SIGCHLD)) {
		// Wake up parent in case they're in waitpid
		sched::wake(&proc.wq);
	};

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
