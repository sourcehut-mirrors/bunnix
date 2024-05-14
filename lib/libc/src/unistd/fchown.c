#define _GNU_SOURCE
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include "syscall.h"

int fchown(int fd, uid_t uid, gid_t gid)
{
	return fchownat(fd, NULL, uid, gid, AT_EMPTY_PATH);
}
