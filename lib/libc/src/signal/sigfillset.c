#include <signal.h>
#include <limits.h>

int sigfillset(sigset_t *set)
{
	*set = ~0;
	return 0;
}
