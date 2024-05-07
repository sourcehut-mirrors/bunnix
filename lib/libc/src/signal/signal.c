#include <signal.h>
#include "syscall.h"

void (*signal(int sig, void (*func)(int)))(int)
{
	// TODO Bunnix
	return 0;
}

weak_alias(signal, bsd_signal);
weak_alias(signal, __sysv_signal);
