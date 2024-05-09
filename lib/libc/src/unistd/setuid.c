#include <unistd.h>
#include "syscall.h"
#include "libc.h"

int setuid(uid_t uid)
{
	struct __creds creds;
	getcreds(&creds);
	creds.uid = uid;
	return setcreds(&creds);
}
