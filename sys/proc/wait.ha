use errors::{error, errno};
use sched;
use log;

export def WNOHANG: int = 1;
export def WUNTRACED: int = 2;
export def WCONTINUED: int = 8;

// Waits for a child process to exit.
export fn waitpid(
	pid: int,
	wstatus: nullable *int,
	options: int,
) (int | error) = {
	const parent = current();
	assert(options & WCONTINUED == 0); // TODO
	assert(options & WUNTRACED == 0); // TODO
	assert(pid >= -1); // TODO

	let link = sched::wq_link { ... };
	const child: nullable *proc = null;
	if (pid > 0) {
		child = getproc(pid)?;

		const child = child as *proc;
		if (child.creds.ppid != parent.creds.pid) {
			return errno::CHILD: error;
		};

		if (!child.exited) {
			if (options & WNOHANG == 1) {
				return 0;
			} else {
				sched::wait(&parent.wq, &link);
			};
		};
	};

	if (child == null && len(parent.children) == 0) {
		return errno::CHILD: error;
	};

	for (child == null) {
		for (let proc .. parent.children) {
			if (proc.exited) {
				child = proc;
				break;
			};
		};

		if (child != null) {
			break;
		};

		if (child == null && options & WNOHANG == 1) {
			return 0;
		};

		sched::wait(&parent.wq, &link);
	};

	const child = child as *proc;
	const pid = child.creds.pid;
	const status = child.status;
	finish(child); // Reap child

	match (wstatus) {
	case let i: *int =>
		*i = status;
	case null => void;
	};

	return pid;
};
