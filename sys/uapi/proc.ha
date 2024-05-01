use errors::{error, errno};
use fs;
use io;
use proc;

fn sys_getpid() (u64 | error) = {
	return proc::current().creds.pid: u64;
};

fn sys_getppid() (u64 | error) = {
	return proc::current().creds.ppid: u64;
};

fn sys_kill(status: int) (u64 | error) = {
	abort(); // TODO
};

fn sys_exit(status: int) (u64 | error) = {
	abort(); // TODO
};

fn sys_fork() (u64 | error) = {
	return proc::fork()?: u64;
};

fn sys_execve(opts: *exec_options) (u64 | error) = {
	assert(opts.flags == 0); // TODO

	validate_user_addr(opts, size(exec_options), false)?;
	validate_user_string(opts.path)?;
	validate_user_slice(opts.args, size(str))?;
	validate_user_slice(opts.environ, size(str))?;
	for (let arg .. opts.args) {
		validate_user_string(arg)?;
	};
	for (let env .. opts.environ) {
		validate_user_string(env)?;
	};

	// TODO:
	// - Check for +x mode
	// - Free/unref inode from walk
	const current = proc::current();
	const (inode, _) = fs::walk(current.root, opts.path)?;
	const file = io::inode_open(inode)!;
	proc::exec(current, file, opts.args, opts.environ)?;

	abort(); // Unreachable
};
