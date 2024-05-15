#include <unistd.h>
#include "syscall.h"

int fdatasync(int fd)
{
	// Data is immediately synced on Bunnix
	return 0;
}
