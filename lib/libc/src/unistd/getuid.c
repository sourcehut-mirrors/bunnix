#include <unistd.h>
#include "syscall.h"

uid_t getuid(void)
{
	struct __creds creds;
	getcreds(&creds);
	return creds.uid;
}
