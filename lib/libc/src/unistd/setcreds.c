#include <unistd.h>
#include "syscall.h"

int setcreds(struct __creds *in)
{
	int ret = syscall(SYS_getcreds, in);
	return __syscall_ret(ret);
}

