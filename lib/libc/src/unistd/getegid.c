#include <unistd.h>
#include "syscall.h"

gid_t getegid(void)
{
	struct __creds creds;
	getcreds(&creds);
	return creds.egid;
}
