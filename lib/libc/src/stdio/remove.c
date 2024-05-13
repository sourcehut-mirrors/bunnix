#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include "syscall.h"

int remove(const char *path)
{
	int r = __syscall(SYS_unlinkat, AT_FDCWD, path, 0);
	if (r==-EISDIR) r = __syscall(SYS_unlinkat, AT_FDCWD, path, AT_REMOVEDIR);
	return __syscall_ret(r);
}
