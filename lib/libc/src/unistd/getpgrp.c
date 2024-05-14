#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include "syscall.h"

pid_t getpgrp(void)
{
	fprintf(stderr, "getpgrp: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
