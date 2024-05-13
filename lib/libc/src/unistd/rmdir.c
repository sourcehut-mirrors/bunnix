#include <unistd.h>
#include <fcntl.h>
#include "syscall.h"

int rmdir(const char *path)
{
	return unlinkat(AT_FDCWD, path, AT_REMOVEDIR);
}
