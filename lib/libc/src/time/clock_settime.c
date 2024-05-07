#include <time.h>
#include <errno.h>
#include "syscall.h"

int clock_settime(clockid_t clk, const struct timespec *ts)
{
	// TODO Bunnix
	errno = EOPNOTSUPP;
	return -1;
}
