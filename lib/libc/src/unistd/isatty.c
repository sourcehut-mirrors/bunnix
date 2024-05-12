#include <errno.h>
#include <sys/stat.h>
#include <unistd.h>
#include "syscall.h"

int isatty(int fd)
{
	// XXX: This is less than ideal
	struct stat st;
	int ret = fstat(fd, &st);
	if (ret < 0) {
		return 0;
	}
	if (st.st_rdev >> 32 == 2) {
		return 1;
	}
	return 0;
}
