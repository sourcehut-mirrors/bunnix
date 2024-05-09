#include <unistd.h>
#include "libc.h"
#include "syscall.h"

int setegid(gid_t egid)
{
	struct __creds creds;
	getcreds(&creds);
	creds.egid = egid;
	return setcreds(&creds);
}
