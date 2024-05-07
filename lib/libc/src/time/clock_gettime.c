#include <time.h>
#include <errno.h>
#include <stdint.h>
#include "syscall.h"
#include "atomic.h"

int __clock_gettime(clockid_t clk, struct timespec *ts)
{
	// TODO Bunnix
	errno = EOPNOTSUPP;
	return -1;
}

weak_alias(__clock_gettime, clock_gettime);
