use arch;
use errors::{error, errno};
use sched;

fn sys_gettime(clock: u64, tp: *timespec) (u64 | error) = {
	validate_user_addr(tp, size(timespec))?;
	return 0u64; // TODO
};

fn sys_nanosleep(req: *timespec) (u64 | error) = {
	validate_user_addr(req, size(timespec))?;

	const rate = arch::getrate();
	const now = arch::gettime();
	let until = req.tv_sec: u64 * rate;
	until += req.tv_nsec: u64 * (rate / 1e9);
	until += now;

	let timer = sched::timer { ... };
	sched::sleep(&timer, until);

	return 0u64;
};
