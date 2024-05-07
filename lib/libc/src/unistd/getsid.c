#include <unistd.h>
#include "syscall.h"

pid_t getsid(pid_t pid)
{
	struct __creds creds;
	getcreds(&creds);
	return creds.sid;
}
