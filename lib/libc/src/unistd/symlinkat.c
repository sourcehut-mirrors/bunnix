#include <errno.h>
#include <unistd.h>
#include "syscall.h"

int symlinkat(const char *existing, int fd, const char *new)
{
	errno = ENOSYS;
	return -1;
}
