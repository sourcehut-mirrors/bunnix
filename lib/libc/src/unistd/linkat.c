#include <string.h>
#include <unistd.h>
#include "syscall.h"

int linkat(int fd1, const char *existing, int fd2, const char *new, int flag)
{
	struct __linkat_options opts = {
		.olddirfd = fd1,
		.oldpath = sys_string(existing, strlen(existing)),
		.newdirfd = fd2,
		.newpath = sys_string(new, strlen(new)),
		.flags = flag,
	};
	return syscall(SYS_linkat, &opts);
}
