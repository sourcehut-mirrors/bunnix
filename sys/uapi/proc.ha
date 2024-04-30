use errors::{error, errno};

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
	abort(); // TODO
};

fn sys_exec(opts: *exec_options) (u64 | error) = {
	abort(); // TODO
};
