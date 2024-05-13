#include <sys/stat.h>
#include <fcntl.h>
#include "syscall.h"

int mkdir(const char *path, mode_t mode)
{
	return mkdirat(AT_FDCWD, path, mode);
}
