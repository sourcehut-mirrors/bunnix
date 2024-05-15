#include <signal.h>

int sigismember(const sigset_t *set, int sig)
{
	unsigned s = sig-1;
	if (s >= _NSIG-1) return 0;
	return (*set & (1 << s)) != 0;
}
