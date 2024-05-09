#include <unistd.h>
#include "syscall.h"
#include "libc.h"

int setgid(gid_t gid)
{
	struct __creds creds;
	getcreds(&creds);
	creds.gid = gid;
	return setcreds(&creds);
}
