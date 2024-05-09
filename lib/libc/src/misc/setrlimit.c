#include <sys/resource.h>
#include <errno.h>
#include "syscall.h"
#include "libc.h"

int setrlimit(int resource, const struct rlimit *rlim)
{
	return 0;
}
