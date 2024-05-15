#include <unistd.h>
#include "syscall.h"

int fsync(int fd)
{
	// Data is immediately synced on Bunnix
	return 0;
}
