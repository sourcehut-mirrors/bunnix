#include <time.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include "syscall.h"
#include "atomic.h"

int __clock_gettime(clockid_t clk, struct timespec *ts)
{
	fprintf(stderr, "clock_gettime: ENOSYS\n");
	// TODO Bunnix
	errno = ENOSYS;
	return -1;
}

weak_alias(__clock_gettime, clock_gettime);
