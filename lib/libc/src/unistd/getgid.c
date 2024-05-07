#include <unistd.h>
#include "syscall.h"

gid_t getgid(void)
{
	struct __creds creds;
	getcreds(&creds);
	return creds.gid;
}
