// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use fmt;
use rt;
use time;
use unix;

// Stores information about a child process.
export type process = unix::pid;

// Returns the currently running [[process]].
export fn self() process = {
	return unix::getpid();
};

// Stores information about an exited process.
export type status = struct {
	status: int,
};

// Waits for a process to complete, then returns its status information.
export fn wait(proc: *process) (status | error) = {
	let st: status = status { ... };
	match (rt::waitpid(*proc, &st.status, 0)) {
	case let err: rt::errno =>
		return errors::errno(err);
	case let pid: rt::pid_t =>
		assert(pid == *proc: rt::pid_t);
	};
	return st;
};

// Waits for the first child process to complete, then returns its process info
// and status
export fn waitany() ((process, status) | error) = {
	let st: status = status { ... };
	match (rt::waitpid(-1, &st.status, 0)) {
	case let err: rt::errno =>
		return errors::errno(err);
	case let pid: rt::pid_t =>
		return (pid, st);
	};
};

// Waits for all children to terminate succesfully. If a child process exits
// with a nonzero status, returns its process info and exit status immediately,
// not waiting for the remaining children.
export fn waitall() (uint | error | !(process, exit_status)) = {
	let st: status = status { ... };
	for (let i = 0u; true; i += 1) {
		const (proc, st) = waitany()?;
		match (check(&st)) {
		case void => void;
		case let es: !exit_status =>
			return (proc, es);
		};
	};
};

// Checks for process completion, returning its status information on
// completion, or void if it is still running.
export fn peek(proc: *process) (status | void | error) = {
	let st: status = status { ... };
	match (rt::waitpid(*proc, &st.status, rt::WNOHANG)) {
	case let err: rt::errno =>
		return errors::errno(err);
	case let pid: rt::pid_t =>
		assert(pid == *proc: rt::pid_t);
		switch (pid) {
		case 0 =>
			return;
		case =>
			assert(pid == *proc: rt::pid_t);
		};
	};
	return st;
};

// Checks if any child process has completed, returning its process info and
// status if so.
export fn peekany() ((process, status) | void | error) = {
	let st: status = status { ... };
	match (rt::waitpid(-1, &st.status, rt::WNOHANG)) {
	case let err: rt::errno =>
		return errors::errno(err);
	case let pid: rt::pid_t =>
		switch (pid) {
		case 0 =>
			return;
		case =>
			return (pid, st);
		};
	};
};

// The exit status code of a process.
export type exited = int;

// The signal number which caused a process to terminate.
export type signaled = int; // TODO

// The exit status of a process.
export type exit_status = (exited | signaled);

// Returns a human friendly string describing the exit status. The string is
// statically allocated; use [[strings::dup]] to extend its lifetime.
export fn exitstr(status: exit_status) const str = {
	static let buf: [1024]u8 = [0...];
	match (status) {
	case let i: exited =>
		switch (i) {
		case 0 =>
			return "exited normally";
		case =>
			return fmt::bsprintf(buf, "exited with status {}",
				i: int);
		};
	case signaled =>
		return fmt::bsprintf(buf, "exited with signal");
	};
};

// Returns the exit status of a completed process.
export fn exit(stat: *status) exit_status = {
	if (rt::wifexited(stat.status)) {
		return rt::wexitstatus(stat.status): exited;
	};
	if (rt::wifsignaled(stat.status)) {
		return rt::wtermsig(stat.status): signaled;
	};
	abort("Unexpected exit status");
};

// Checks the exit status of a completed process, returning void if successful,
// or its status code as an error type if not.
export fn check(stat: *status) (void | !exit_status) = {
	if (rt::wifexited(stat.status)) {
		switch (rt::wexitstatus(stat.status)) {
		case 0 =>
			return void;
		case =>
			return exit(stat);
		};
	};
	return exit(stat);
};
