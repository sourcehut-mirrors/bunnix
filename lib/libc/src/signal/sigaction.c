#include <signal.h>
#include <errno.h>
#include <string.h>
#include "syscall.h"
#include "libc.h"

int __sigaction(int sig, const struct sigaction *restrict sa, struct sigaction *restrict old)
{
	int r = syscall(SYS_sigaction, sig, sa, old);
	return __syscall_ret(r);
}

weak_alias(__sigaction, sigaction);
