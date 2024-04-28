use errors::{error, errno};

const UAPI: str = "uapi";

export fn syscall(
	sysno: u64,
	a1: u64,
	a2: u64,
	a3: u64,
	a4: u64,
	a5: u64,
) (u64, u64) = {
	if (sysno: size >= len(systab)) {
		return (errno::NOSYS, 0);
	};
	const func = systab[sysno]: *syscall_handler;
	match (func(a1, a2, a3, a4)) {
	case let e: error =>
		return (e: errno, 0);
	case let u: u64 =>
		return (errno::NONE, u);
	};
};
