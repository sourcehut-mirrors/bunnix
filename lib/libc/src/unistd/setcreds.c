#include <unistd.h>
#include "syscall.h"

int setcreds(struct __creds *in)
{
	return syscall(SYS_getcreds, in);
}

