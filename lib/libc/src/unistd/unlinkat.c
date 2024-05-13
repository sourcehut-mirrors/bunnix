#include <string.h>
#include <unistd.h>
#include "syscall.h"

int unlinkat(int fd, const char *path, int flag)
{
	struct __unlinkat_options opts = {
		.dirfd = fd,
		.path = sys_string(path, strlen(path)),
		.flags = flag,
	};
	return syscall(SYS_unlinkat, &opts);
}
