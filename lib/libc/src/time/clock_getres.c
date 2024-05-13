#include <time.h>
#include <stdio.h>
#include "syscall.h"

int clock_getres(clockid_t clk, struct timespec *ts)
{
	fprintf(stderr, "clock_getres: ENOSYS\n");
	// TODO Bunnix
	errno = ENOSYS;
	return -1;
}
