#define _BSD_SOURCE
#include <sys/stat.h>
#include <fcntl.h>

int futimens(int fd, const struct timespec times[2])
{
	return utimensat(fd, 0, times, AT_EMPTY_PATH);
}
