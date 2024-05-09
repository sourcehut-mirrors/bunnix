#include <sys/resource.h>
#include <errno.h>
#include "syscall.h"

int getrlimit(int resource, struct rlimit *rlim)
{
	errno = EOPNOTSUPP;
	return -1;
}
