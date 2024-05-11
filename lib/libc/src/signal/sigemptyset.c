#include <signal.h>
#include <string.h>

int sigemptyset(sigset_t *set)
{
	*set = 0;
	return 0;
}
