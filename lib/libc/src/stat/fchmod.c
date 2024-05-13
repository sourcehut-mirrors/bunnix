#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <sys/stat.h>
#include "syscall.h"

int fchmod(int fd, mode_t mode)
{
	return fchmodat(AT_FDCWD, NULL, mode, 0);
}
