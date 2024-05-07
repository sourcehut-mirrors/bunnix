#include <unistd.h>
#include "syscall.h"

void getcreds(struct __creds *out)
{
	syscall(SYS_getcreds, out);
}
