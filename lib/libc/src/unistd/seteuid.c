#include <unistd.h>
#include "syscall.h"
#include "libc.h"

int seteuid(uid_t euid)
{
	struct __creds creds;
	getcreds(&creds);
	creds.euid = euid;
	return setcreds(&creds);
}
