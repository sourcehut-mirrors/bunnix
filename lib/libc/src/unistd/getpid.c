#include <unistd.h>
#include "syscall.h"

pid_t getpid(void)
{
	struct __creds creds;
	getcreds(&creds);
	return creds.pid;
}
