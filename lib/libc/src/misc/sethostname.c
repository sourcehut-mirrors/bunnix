#include <string.h>
#include <unistd.h>
#include "syscall.h"

int sethostname(const char *name, size_t len)
{
	__string_t hostname = sys_string(name, len);
	return syscall(SYS_sethostname, &hostname);
}
