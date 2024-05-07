#include <time.h>
#include "syscall.h"

int clock_getres(clockid_t clk, struct timespec *ts)
{
	// TODO Bunnix
	errno = EOPNOTSUPP;
	return -1;
}
