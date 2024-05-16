use arch;
use errors::{error, errno};
use mman;
use sched;

// Delivers a signal to the specified process.
//
// Returns true if the signal was queued, and false if it was ignored or
// blocked.
export fn signal(proc: *proc, signo: sig) bool = {
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
		return false;
	};

	sigaddset(&sigproc.pending, signo)!;

	sched::wake(&proc.wq);

	return true;
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

	sigdelset(&proc.sig.pending, signo)!;

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
	sched::prepare_task(task);

	let frame = sp: *signal_stack;
	if (!mman::isvalid(frame, size(signal_stack), true, &proc.vmm)) {
		// TODO: Exit with segfault
		exit(1);
	};

	frame.sigreturn = arch::SIGRETURN_MAGIC;
	frame.ctx = task.ctx;
	frame.restore = task.restore;
	frame.syscall = task.syscall;

	arch::context_set_sp(&task.ctx, sp);
	arch::context_set_ip(&task.ctx, act.sa_handler: uintptr);
	arch::context_set_abi(&task.ctx, signo: u64);
	sched::enter_user(task);
};

// Called by the ISR's magic signal return routine.
export fn return_signal(ctx: *arch::context) void = {
	const task = sched::task_fromctx(ctx);
	const proc = task.user: *proc;

	let sp = arch::context_get_sp(ctx);

	sp -= size(uintptr): uintptr;
	let frame = sp: *signal_stack;

	if (!mman::isvalid(frame, size(signal_stack), true, &proc.vmm)) {
		abort(); // TODO: Do something here
	};

	assert(frame.sigreturn == arch::SIGRETURN_MAGIC);
	*ctx = frame.ctx;

	if (frame.syscall != -1) {
		// Return from syscall with EINTR
		arch::context_set_rval(&task.ctx, errno::INTR, 0);
		arch::set_restore_point(&frame.restore, &arch::sysret: uintptr);
		arch::restore(&frame.restore);
	};
};
