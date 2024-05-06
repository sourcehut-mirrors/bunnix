#include <unistd.h>
#include <errno.h>
#include "libc.h"
#include "fork_impl.h"

pid_t fork(void)
{
	return _Fork();
}
