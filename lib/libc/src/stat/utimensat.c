#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include "syscall.h"

int utimensat(int fd, const char *path, const struct timespec times[2], int flags)
{
	fprintf(stderr, "utimensat: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
