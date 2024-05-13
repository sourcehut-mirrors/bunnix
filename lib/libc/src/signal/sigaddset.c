#include <signal.h>
#include <errno.h>

int sigaddset(sigset_t *set, int sig)
{
	unsigned s = sig-1;
	if (s >= _NSIG-1 || sig-32U < 3) {
		errno = EINVAL;
		return -1;
	}
	*set |= 1 << sig;
	return 0;
}
