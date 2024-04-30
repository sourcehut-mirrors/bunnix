use errors::{error, errno};
use proc;

fn sys_getpid(status: int) (u64 | error) = {
	abort(); // TODO
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

fn sys_exec(opts: *exec_options) (u64 | error) = {
	abort(); // TODO
};
