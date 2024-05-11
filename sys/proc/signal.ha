use arch;
use mman;
use sched;

// Delivers a signal to the specified process.
export fn signal(proc: *proc, signo: sig) void = {
	assert(signo >= 1 && signo <= sig::SIGMAX);
	assert(sigdefault[signo] != action::CONT); // TODO

	let sigproc = &proc.sig;
	const awaited = sigismember(&sigproc.awaited, signo);
	const ignored = sigproc.action[signo].sa_handler == SIG_IGN
		&& sigdefault[signo] == action::IGNO;
	const blocked = sigismember(&sigproc.blocked, signo) &&
		signo != sig::SIGKILL && signo != sig::SIGSTOP;

	if (!awaited && !blocked && ignored) {
		// Do nothing
		return;
	};

	sigaddset(&sigproc.pending, signo)!;

	// TODO: interrupt processes blocked on syscalls more generally
	sched::wake(&proc.wq);
};

// Called by the scheduler to handle any pending signals for this task. Returns
// false if the signal causes this task to no longer be scheduable (e.g.
// SIGKILL).
export fn resume_signal(task: *sched::task) bool = {
	// XXX: This assumes that every task is associated with a process, if we
	// add kthreads this may not always be true.
	const proc = task.user: *proc;

	let signo = 0: sig;
	for (let i = 1: sig; i <= sig::SIGMAX; i += 1) {
		if (sigismember(&proc.sig.pending, i)) {
			signo = i;
			break;
		};
	};
	if (signo == 0) {
		return true;
	};

	const act = &proc.sig.action[signo];
	assert(act.flags & SA_SIGINFO == 0); // TODO
	if (act.sa_handler == SIG_DFL) {
		const act = sigdefault[signo];
		switch (act) {
		case action::TERM, action::ABRT =>
			exit(1); // TODO: Exit with signal status
		case action::IGNO =>
			return true;
		case action::STOP =>
			abort(); // TODO: Job control
		case action::CONT =>
			abort(); // TODO: Job control
		};
	};

	let sp = arch::context_get_sp(&task.ctx);
	sp -= 128; // Red zone
	sp &= 0xFFFFFFFFFFFFFFF0: uintptr; // Alignment
	sp -= size(signal_stack): uintptr;

	// Deliver signal
	mman::vmm_map(&proc.vmm);

	if (!mman::isvalid(&proc.vmm, sp, size(signal_stack), true)) {
		// TODO: Exit with segfault
		exit(1);
	};

	let frame = sp: *signal_stack;
	frame.sigreturn = arch::SIGRETURN_MAGIC;

	arch::context_set_sp(&task.ctx, sp);
	arch::context_set_ip(&task.ctx, act.sa_handler: uintptr);
	arch::context_set_abi(&task.ctx, signo: u64);
	arch::enter_user(&task.ctx);
};
