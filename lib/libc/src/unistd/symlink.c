#include <unistd.h>
#include <fcntl.h>
#include "syscall.h"

int symlink(const char *existing, const char *new)
{
	return symlinkat(existing, AT_FDCWD, new);
}
