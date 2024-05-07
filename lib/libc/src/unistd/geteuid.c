#include <unistd.h>
#include "syscall.h"

uid_t geteuid(void)
{
	struct __creds creds;
	getcreds(&creds);
	return creds.euid;
}
