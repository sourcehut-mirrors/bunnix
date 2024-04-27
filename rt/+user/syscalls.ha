fn syscall(sysno: u64, ...) u64;

// Test syscall
export fn test(a: u64, b: u64, c: u64) void = {
	syscall(SYS_test, a, b, c);
};
