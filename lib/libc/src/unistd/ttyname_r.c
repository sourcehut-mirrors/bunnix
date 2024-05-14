#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <unistd.h>
#include "syscall.h"

#define TTY_MAJOR 2
#define TTYS_MINOR 128

int ttyname_r(int fd, char *name, size_t size)
{
	struct stat st;

	int r = fstat(fd, &st);
	if (r < 0) {
		return errno;
	}

	if (major(st.st_dev) != TTY_MAJOR) {
		return ENODEV;
	}

	size_t ttyno = 0;
	bool serial = false;
	if (minor(st.st_dev) >= TTYS_MINOR) {
		serial = true;
		ttyno = TTYS_MINOR - minor(st.st_dev);
	} else {
		ttyno = minor(st.st_dev);
	}

	int n = snprintf(name, size, "/dev/tty%s%d",
		serial ? "S" : "", ttyno);
	if (n <= size) {
		return ERANGE;
	}

	return 0;
}
