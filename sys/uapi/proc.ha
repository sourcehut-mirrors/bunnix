use arch;
use errors::{error, errno};
use fs;
use io;
use path;
use proc;
use sched;
use strings;

fn sys_kill(pid: i64, sig: i64) (u64 | error) = {
	if (sig < 1 || sig > proc::sig::SIGMAX) {
		return errno::INVAL: error;
	};

	assert(pid > 0); // TODO
	const cur = proc::current();
	const targ = proc::getproc(pid: int)?;

	const tests = [
		cur.creds.uid == 0,
		cur.creds.euid == 0,
		cur.creds.uid == targ.creds.uid,
		cur.creds.uid == targ.creds.euid,
		cur.creds.euid == targ.creds.uid,
		cur.creds.euid == targ.creds.euid,
	];
	let valid = false;
	for (let test .. tests) {
		valid ||= test;
	};
	if (!valid) {
		return errno::PERM: error;
	};

	proc::signal(targ, sig: proc::sig);

	return 0u64;
};

fn sys_exit(status: i64) (u64 | error) = {
	proc::exit(status: int);
};

fn sys_sigaction(
	sig: i64,
	new: nullable *proc::sigaction,
	old: nullable *proc::sigaction,
) (u64 | error) = {
	if (new != null) {
		validate_user_addr(new, size(proc::sigaction))?;
	};
	if (old != null) {
		validate_user_addr(old, size(proc::sigaction))?;
	};

	const sig = sig: proc::sig;
	if (sig < 1 || sig >= proc::sig::SIGMAX) {
		return errno::INVAL: error;
	};
	if (sig == proc::sig::SIGKILL || sig == proc::sig::SIGSTOP) {
		return errno::INVAL: error;
	};

	const cur = proc::current();
	let sigproc = &cur.sig;
	match (old) {
	case let sa: *proc::sigaction =>
		*sa = sigproc.action[sig];
	case null => void;
	};

	match (new) {
	case let sa: *proc::sigaction =>
		sigproc.action[sig] = *sa;
	case null => void;
	};

	return 0u64;
};

fn sys_fork() (u64 | error) = {
	return proc::fork()?: u64;
};

fn sys_execve(opts: *exec_options) (u64 | error) = {
	validate_user_addr(opts, size(exec_options), false)?;

	validate_user_slice(opts.args, size(str))?;
	validate_user_slice(opts.environ, size(str))?;
	for (let arg .. opts.args) {
		validate_user_string(arg)?;
	};
	for (let env .. opts.environ) {
		validate_user_string(env)?;
	};

	const current = proc::current();
	const file = if (opts.flags & exec_flag::FEXECVE != 0) {
		yield validate_file(opts.fd)?;
	} else {
		validate_user_string(opts.path)?;
		// TODO: Should we have an fexecveat?
		const (inode, _) = atwalk(AT_FDCWD, opts.path)?;
		yield io::inode_open(inode)!;
	};

	// TODO:
	// - Check for +x mode
	// - Free/unref inode from walk
	proc::exec(current, file, opts.args, opts.environ)?;

	abort(); // Unreachable
};

fn sys_waitpid(pid: i64, wstatus: nullable *int, options: i64) (u64 | error) = {
	if (wstatus != null) {
		validate_user_addr(wstatus, size(int))?;
	};

	return proc::waitpid(pid: int, wstatus, options: int)?: u64;
};

fn sys_getcreds(out: *creds) (u64 | error) = {
	validate_user_addr(out, size(creds), true)?;
	validate_user_slice(out.groups, size(int), true)?;

	const cur = &proc::current().creds;
	out.pid = cur.pid;
	out.ppid = cur.ppid;
	out.pgid = cur.pgid;
	out.sid = cur.sid;
	out.uid = cur.uid;
	out.euid = cur.euid;
	out.egid = cur.egid;
	out.ngroup = len(cur.groups);

	let groups = cur.groups;
	if (len(groups) > len(out.groups)) {
		groups = groups[..len(out.groups)];
	};
	out.groups[..] = groups[..];

	return 0u64;
};

fn sys_setcreds(in: *creds) (u64 | error) = {
	validate_user_addr(in, size(creds))?;
	validate_user_slice(in.groups, size(int))?;

	const cur = &proc::current().creds;
	if (cur.euid != 0) {
		// TODO: This is probably more complex in practice
		return errno::PERM: error;
	};
	cur.uid = in.uid;
	cur.euid = in.euid;
	cur.gid = in.gid;
	cur.egid = in.egid;

	return 0u64;
};

fn sys_setgroups(groups: *[*]int, ngroup: size) (u64 | error) = {
	validate_user_addr(groups, size(int) * ngroup)?;
	const groups = groups[..ngroup];

	const cur = &proc::current().creds;
	if (cur.euid != 0) {
		// TODO: This is probably more complex in practice
		return errno::PERM: error;
	};

	free(cur.groups);
	cur.groups = alloc([], len(groups));
	append(cur.groups, groups...);

	return 0u64;
};

fn sys_chdirat(opts: *chdirat_options) (u64 | error) = {
	validate_user_addr(opts, size(chdirat_options))?;
	assert(opts.flags & AT_EMPTY_PATH == 0); // TODO
	assert(opts.dirfd == AT_FDCWD); // TODO

	validate_user_string(opts.path)?;

	const (targ, _) = atwalk(opts.dirfd, opts.path)?;

	if (!io::isdir(targ.mode)) {
		io::inode_unref(targ);
		return errno::NOTDIR: error;
	};

	let cur = proc::current();
	io::inode_unref(cur.cwd);
	cur.cwd = targ;

	const path = path::init(cur.cwd_str)!;
	if (path::abs(opts.path)) {
		path::set(&path, opts.path)!;
	} else {
		path::push(&path, opts.path)!;
	};
	free(cur.cwd_str);
	cur.cwd_str = strings::dup(path::string(&path));

	return 0u64;
};

fn sys_getcwd(buf: *[*]u8, bufsz: size) (u64 | error) = {
	validate_user_addr(buf, bufsz)?;

	const cwd = proc::current().cwd_str;

	let buf = buf[..bufsz];
	if (bufsz < len(cwd) + 1) {
		return errno::RANGE: error;
	};

	buf[..len(cwd)] = strings::toutf8(cwd)[..];
	buf[len(cwd)] = 0;
	return 0u64;
};
