#include <time.h>
#include <errno.h>
#include <stdio.h>
#include "syscall.h"

int clock_settime(clockid_t clk, const struct timespec *ts)
{
	// TODO Bunnix
	fprintf(stderr, "clock_settime: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
