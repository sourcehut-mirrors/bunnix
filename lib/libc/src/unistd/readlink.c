#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include "syscall.h"

ssize_t readlink(const char *restrict path, char *restrict buf, size_t bufsize)
{
	fprintf(stderr, "readlink: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
