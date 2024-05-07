#include <signal.h>
#include <errno.h>
#include <string.h>
#include "syscall.h"
#include "libc.h"

int __sigaction(int sig, const struct sigaction *restrict sa, struct sigaction *restrict old)
{
	// TODO Bunnix
	return 0;
}

weak_alias(__sigaction, sigaction);
