#include <errno.h>
#include <stdio.h>
#include <sys/stat.h>
#include "syscall.h"

int mknodat(int fd, const char *path, mode_t mode, dev_t dev)
{
	fprintf(stderr, "mknodat: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
