use log;

const UAPI: str = "uapi";

export fn syscall(
	sysno: u64,
	a1: u64,
	a2: u64,
	a3: u64,
	a4: u64,
	a5: u64,
) (u64, u64) = {
	log::kprintfln(UAPI, "syscall no: {}; a1: {}; a2: {}; a3: {}",
		sysno, a1, a2, a3);
	return (0, 0);
};
