#include <sys/stat.h>
#include <string.h>
#include "syscall.h"

int mkdirat(int fd, const char *path, mode_t mode)
{
	struct __mkdirat_options opts = {
		.dirfd = fd,
		.path = sys_string(path, strlen(path)),
		.mode = mode,
	};
	return syscall(SYS_mkdirat, &opts);
}
