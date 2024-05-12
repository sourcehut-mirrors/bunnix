#include <signal.h>
#include <errno.h>
#include <string.h>
#include "syscall.h"
#include "libc.h"

int __sigaction(int sig, const struct sigaction *restrict sa, struct sigaction *restrict old)
{
	return syscall(SYS_sigaction, sig, sa, old);
}

weak_alias(__sigaction, sigaction);
