#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include "syscall.h"

int fchownat(int fd, const char *path, uid_t uid, gid_t gid, int flag)
{
	fprintf(stderr, "fchownat: ENOSYS\n");
	errno = ENOSYS;
	return -1;
}
