#include <errno.h>
#include <stdio.h>
#include <sys/file.h>
#include "syscall.h"

int flock(int fd, int op)
{
	fprintf(stderr, "flock: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
