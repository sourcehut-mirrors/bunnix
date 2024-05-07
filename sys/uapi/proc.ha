use arch;
use errors::{error, errno};
use fs;
use io;
use proc;
use sched;
// XXX TEMP
use log;

fn sys_kill(status: int) (u64 | error) = {
	abort(); // TODO
};

fn sys_exit(status: int) (u64 | error) = {
	proc::exit(status);
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

fn sys_chdirat(opts: *chdirat_options) (u64 | error) = {
	validate_user_addr(opts, size(chdirat_options))?;

	const targ = if (opts.flags & AT_EMPTY_PATH == 1) {
		const fd = validate_dirfd(opts.dirfd)?;
		yield fd.inode as *io::inode;
	} else {
		validate_user_string(opts.path)?;

		const (ino, _) = atwalk(opts.dirfd, opts.path)?;
		yield ino;
	};

	let cur = proc::current();
	io::inode_unref(cur.cwd);
	cur.cwd = targ;

	return 0u64;
};
