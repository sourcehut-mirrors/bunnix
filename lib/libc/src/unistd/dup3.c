#define _GNU_SOURCE
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include "syscall.h"

int __dup3(int old, int new, int flags)
{
	int r = syscall(SYS_dup2, old, new, flags);
	return __syscall_ret(r);
}

weak_alias(__dup3, dup3);
