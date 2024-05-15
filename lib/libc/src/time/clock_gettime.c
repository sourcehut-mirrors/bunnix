#include <time.h>
#include <stdint.h>
#include "syscall.h"
#include "atomic.h"

int __clock_gettime(clockid_t clk, struct timespec *ts)
{
	return syscall(SYS_gettime, clk, ts);
}

weak_alias(__clock_gettime, clock_gettime);
