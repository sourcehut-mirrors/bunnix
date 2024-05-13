#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include "syscall.h"

int faccessat(int fd, const char *filename, int amode, int flag)
{
	struct __faccessat_options opts = {
		.dirfd = fd,
		.path = sys_string(filename, strlen(filename)),
		.flags = flag,
	};
	return syscall(SYS_faccessat, &opts);
}
