#include <string.h>
#include <sys/stat.h>
#include "syscall.h"

int mknodat(int fd, const char *path, mode_t mode, dev_t dev)
{
	struct __mknodat_options opts = {
		.dirfd = fd,
		.path = sys_string(path, strlen(path)),
		.mode = mode,
		.dev = dev,
	};
	return syscall(SYS_mknodat, &opts);
}
