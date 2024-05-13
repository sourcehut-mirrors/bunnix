#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>
#include "syscall.h"

unsigned alarm(unsigned seconds)
{
	// TODO Bunnix
	fprintf(stderr, "alarm: ENOSYS\n");
	return 0;
}
