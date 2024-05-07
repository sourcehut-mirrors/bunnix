#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include "syscall.h"

int dup2(int old, int new)
{
	int r = syscall(SYS_dup2, old, new, 0);
	return __syscall_ret(r);
}
