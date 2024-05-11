use errors::{error, errno};

export def NSIG: int = 64;

// Signal number assignments
export type sig = enum int {
	SIGABRT = 1,
	SIGALRM,
	SIGBUS,
	SIGCHLD,
	SIGCONT,
	SIGFPE,
	SIGHUP,
	SIGILL,
	SIGINT,
	SIGKILL,
	SIGPIPE,
	SIGQUIT,
	SIGSEGV,
	SIGSTOP,
	SIGTERM,
	SIGTSTP,
	SIGTTIN,
	SIGTTOU,
	SIGUSR1,
	SIGUSR2,
	SIGPROF,
	SIGSYS,
	SIGTRAP,
	SIGURG,
	SIGVTALRM,
	SIGXCPU,
	SIGXFSZ,

	SIGMAX = SIGXFSZ,
};

// A code indicating why a signal was sent.
export type errcode = enum int {
	USER = 0,
	KERNEL = 128,
	QUEUE = -1,
	TIMER = -2,
	MESQ = -3,
	ASYNCIO = -4,

	ILLOPC = 1,	// sig::ILL: illegal opcode
	ILLOPN = 2,	// sig::ILL: illegal operand
	ILLADR = 3,	// sig::ILL: illegal addressing mode
	ILLTRP = 4,	// sig::ILL: illegal trap
	PRVOPC = 5,	// sig::ILL: privileged opcode
	PRVREG = 6,	// sig::ILL: privileged register
	COPROC = 7,	// sig::ILL: coprocessor error
	BADSTK = 8,	// sig::ILL: internal stack error

	INTDIV = 1,	// sig::FPE: integer divide by zero
	INTOVF = 2,	// sig::FPE: integer overflow
	FLTDIV = 3,	// sig::FPE: floating-point divide by zero
	FLTOVF = 4,	// sig::FPE: floating-point overflow
	FLTUND = 5,	// sig::FPE: floating-point underflow
	FLTRES = 6,	// sig::FPE: floating-point inexact result
	FLTINV = 7,	// sig::FPE: invalid floating-point operation
	FLTSUB = 8,	// sig::FPE: subscript out of range

	MAPERR = 1,	// sig::SEGV: address not mapped to object
	ACCERR = 2,	// sig::SEGV: invalid permissions for mapped object

	ADRALN = 1,	// sig::BUS: invalid address alignment
	ADRERR = 2,	// sig::BUS: nonexistent physical address
	OBJERR = 3,	// sig::BUS: object-specific hardware error

	BRKPT = 1,	// sig::TRAP: process breakpoint
	TRACE = 2,	// sig::TRAP: process trace trap

	EXITED = 1,	// sig::CHLD: child exited
	KILLED = 2,	// sig::CHLD: child terminated abnormally without a core file
	DUMPED = 3,	// sig::CHLD: child terminated abnormally with a core file
	TRAPPED = 4,	// sig::CHLD: traced child has trapped
	STOPPED = 5,	// sig::CHLD: child has stopped
	CONTINUED = 6,	// sig::CHLD: stopped child has continued

	IN = 1,		// sig::POLL: data input available
	OUT = 2,	// sig::POLL: output buffers available
	MSG = 3,	// sig::POLL: input message available
	ERR = 4,	// sig::POLL: I/O error
	PRI = 5,	// sig::POLL: high priority input available
	HUP = 6,	// sig::POLL: device disconnected
};


// Action to perform upon receiving a signal.
type action = enum uint {
	TERM,
	ABRT,
	IGNO,
	STOP,
	CONT,
};

// Default action for each signal.
let sigdefault: [_]action = [
	action::IGNO,	// 0
	action::ABRT,	// SIGABRT
	action::TERM,	// SIGALRM
	action::ABRT,	// SIGBUS
	action::IGNO,	// SIGCHLD
	action::CONT,	// SIGCONT
	action::ABRT,	// SIGFPE
	action::TERM,	// SIGHUP
	action::ABRT,	// SIGILL
	action::TERM,	// SIGINT
	action::TERM,	// SIGKILL
	action::TERM,	// SIGPIPE
	action::ABRT,	// SIGQUIT
	action::ABRT,	// SIGSEGV
	action::STOP,	// SIGSTOP
	action::TERM,	// SIGTERM
	action::STOP,	// SIGTSTP
	action::STOP,	// SIGTTIN
	action::STOP,	// SIGTTOU
	action::TERM,	// SIGUSR1
	action::TERM,	// SIGUSR2
	action::TERM,	// SIGPOLL
	action::TERM,	// SIGPROF
	action::ABRT,	// SIGSYS
	action::ABRT,	// SIGTRAP
	action::IGNO,	// SIGURG
	action::TERM,	// SIGVTALRM
	action::ABRT,	// SIGXCPU
	action::ABRT,	// SIGXFSZ
];

export type sigset = u64;

// Initializes an empty signal set.
export fn sigemptyset(set: *sigset) void = {
	*set = 0;
};

// Returns true if this signal set is empty.
export fn sigisemptyset(set: *sigset) bool = {
	return *set == 0;
};

// Adds the given signal to a signal set.
export fn sigaddset(set: *sigset, signum: int) (void | error) = {
	if (signum < 1 || signum > NSIG) {
		return errno::INVAL;
	};
	signum -= 1;
	*set |= (1 << signum): u64;
};

// Deletes the given signals from a signal set.
export fn sigdelset(set: *sigset, signum: int) (void | error) = {
	if (signum < 1 || signum > NSIG) {
		return errno::INVAL;
	};
	signum -= 1;
	*set &= ~(1 << signum: u64);
};

// Returns true if this signal is a member of this signal set.
export fn sigismember(set: *sigset, signum: int) bool = {
	assert(signum >= 1 && signum <= NSIG);
	signum -= 1;
	return (*set & (1 << signum: u64)) != 0;
};

// Fills all signals in this signal set.
export fn sigfillset(set: *sigset) void = {
	*set = ~0u64;
};

export type siginfo = union {
	si_signo: int,
	si_errno: int,
	si_code: int,
	// TODO: add more stuff here
};

export def SA_NOCLDSTOP = 0x00000001;
export def SA_NOCLDWAIT = 0x00000002;
export def SA_SIGINFO = 0x00000004;
export def SA_ONSTACK = 0x08000000;
export def SA_RESTART = 0x10000000;
export def SA_NODEFER = 0x40000000;
export def SA_RESETHAND = 0x80000000;

export def SIG_ERR: uintptr = -1;
export def SIG_DFL: uintptr = 0;
export def SIG_IGN: uintptr = 1;
export def SIG_HOLD: uintptr = 2;

export type sigaction = struct {
	union {
		sa_handler: nullable *fn(int) void,
		sa_sigaction: nullable *fn(int, *siginfo, *opaque) void,
	},
	sa_mask: sigset,
	flags: int,
	restorer: nullable *fn() void,
};

export type sigproc = struct {
	action: [sig::SIGMAX]sigaction,
	blocked: sigset,
	pending: sigset,
	awaited: sigset,
};
