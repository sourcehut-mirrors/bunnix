#include <unistd.h>
#include "syscall.h"
#include "libc.h"
#include "fork_impl.h"

pid_t _Fork(void)
{
	pid_t ret = __syscall(SYS_fork);
	return __syscall_ret(ret);
}
