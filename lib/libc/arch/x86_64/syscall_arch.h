#define __SYSCALL_LL_E(x) (x)
#define __SYSCALL_LL_O(x) (x)

static __inline long __syscall0(long n)
{
	unsigned long err, ret;
	__asm__ __volatile__ ("syscall"
			: "=a"(err), "=d"(ret)
			: "D"(n)
			: "rcx", "r11", "memory");
	if (err != 0) {
		return -err;
	};
	return ret;
}

static __inline long __syscall1(long n, long a1)
{
	unsigned long err, ret;
	__asm__ __volatile__ ("syscall"
			: "=a"(err), "=d"(ret)
			: "D"(n), "S"(a1)
			: "rcx", "r11", "memory");
	if (err != 0) {
		return -err;
	};
	return ret;
}

static __inline long __syscall2(long n, long a1, long a2)
{
	unsigned long err, ret;
	__asm__ __volatile__ ("syscall"
			: "=a"(err), "=d"(ret)
			: "D"(n), "S"(a1), "d"(a2)
			: "rcx", "r11", "memory");
	if (err != 0) {
		return -err;
	};
	return ret;
}

static __inline long __syscall3(long n, long a1, long a2, long a3)
{
	unsigned long err, ret;
	register long r10 __asm__("r10") = a3;
	__asm__ __volatile__ ("syscall"
			: "=a"(err), "=d"(ret)
			: "D"(n), "S"(a1), "d"(a2), "r"(r10)
			: "rcx", "r11", "memory");
	if (err != 0) {
		return -err;
	};
	return ret;
}

static __inline long __syscall4(long n, long a1, long a2, long a3, long a4)
{
	unsigned long err, ret;
	register long r10 __asm__("r10") = a3;
	register long r8 __asm__("r8") = a4;
	__asm__ __volatile__ ("syscall"
			: "=a"(err), "=d"(ret)
			: "D"(n), "S"(a1), "d"(a2), "r"(r10), "r"(r8)
			: "rcx", "r11", "memory");
	if (err != 0) {
		return -err;
	};
	return ret;
}

static __inline long __syscall5(long n, long a1, long a2, long a3, long a4, long a5)
{
	unsigned long err, ret;
	register long r10 __asm__("r10") = a3;
	register long r8 __asm__("r8") = a4;
	register long r9 __asm__("r9") = a5;
	__asm__ __volatile__ ("syscall"
			: "=a"(err), "=d"(ret)
			: "D"(n), "S"(a1), "d"(a2), "r"(r10), "r"(r8), "r"(r9)
			: "rcx", "r11", "memory");
	if (err != 0) {
		return -err;
	};
	return ret;
}
