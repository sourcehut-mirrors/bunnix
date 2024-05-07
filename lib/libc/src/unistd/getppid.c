#include <unistd.h>
#include "syscall.h"

pid_t getppid(void)
{
	struct __creds creds;
	getcreds(&creds);
	return creds.ppid;
}
