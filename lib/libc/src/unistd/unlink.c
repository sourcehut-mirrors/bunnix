#include <unistd.h>
#include <fcntl.h>
#include "syscall.h"

int unlink(const char *path)
{
	return unlinkat(AT_FDCWD, path, 0);
}
