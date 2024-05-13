#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include "syscall.h"

int ftruncate(int fd, off_t length)
{
	fprintf(stderr, "ftruncate: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
