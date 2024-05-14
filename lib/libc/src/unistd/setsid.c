#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include "syscall.h"

pid_t setsid(void)
{
	fprintf(stderr, "setsid: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
