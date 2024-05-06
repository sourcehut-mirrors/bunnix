#ifndef __DEFINED_SYSRET_T
#define __DEFINED_SYSRET_T
typedef struct {
	unsigned long r1;
	unsigned long r2;
} sysret_t;
#endif

static __inline sysret_t __syscall0(long n)
{
	unsigned long r1, r2;
	__asm__ __volatile__ ("syscall"
			: "=a"(r1), "=d"(r2)
			: "a"(n)
			: "rcx", "r11", "memory");
	return (sysret_t){r1, r2};
}

static __inline sysret_t __syscall1(long n, long a1)
{
	unsigned long r1, r2;
	__asm__ __volatile__ ("syscall"
			: "=a"(r1), "=d"(r2)
			: "a"(n), "D"(a1)
			: "rcx", "r11", "memory");
	return (sysret_t){r1, r2};
}

static __inline sysret_t __syscall2(long n, long a1, long a2)
{
	unsigned long r1, r2;
	__asm__ __volatile__ ("syscall"
			: "=a"(r1), "=d"(r2)
			: "a"(n), "D"(a1), "S"(a2)
			: "rcx", "r11", "memory");
	return (sysret_t){r1, r2};
}

static __inline sysret_t __syscall3(long n, long a1, long a2, long a3)
{
	unsigned long r1, r2;
	__asm__ __volatile__ ("syscall"
			: "=a"(r1), "=d"(r2)
			: "a"(n), "D"(a1), "S"(a2), "d"(a3)
			: "rcx", "r11", "memory");
	return (sysret_t){r1, r2};
}

static __inline sysret_t __syscall4(long n, long a1, long a2, long a3, long a4)
{
	unsigned long r1, r2;
	register long r10 __asm__("r10") = a4;
	__asm__ __volatile__ ("syscall"
			: "=a"(r1), "=d"(r2)
			: "a"(n), "D"(a1), "S"(a2), "d"(a3), "r"(r10)
			: "rcx", "r11", "memory");
	return (sysret_t){r1, r2};
}

static __inline sysret_t __syscall5(long n, long a1, long a2, long a3, long a4, long a5)
{
	unsigned long r1, r2;
	register long r10 __asm__("r10") = a4;
	register long r8 __asm__("r8") = a5;
	__asm__ __volatile__ ("syscall"
			: "=a"(r1), "=d"(r2)
			: "a"(n), "D"(a1), "S"(a2), "d"(a3), "r"(r10), "r"(r8)
			: "rcx", "r11", "memory");
	return (sysret_t){r1, r2};
}

static __inline sysret_t __syscall6(long n, long a1, long a2, long a3, long a4, long a5, long a6)
{
	unsigned long r1, r2;
	register long r10 __asm__("r10") = a4;
	register long r8 __asm__("r8") = a5;
	register long r9 __asm__("r9") = a6;
	__asm__ __volatile__ ("syscall"
			: "=a"(r1), "=d"(r2)
			: "a"(n), "D"(a1), "S"(a2), "d"(a3), "r"(r10), "r"(r8), "r"(r9)
			: "rcx", "r11", "memory");
	return (sysret_t){r1, r2};
}
