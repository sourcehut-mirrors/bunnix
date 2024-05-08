#include <unistd.h>
#include "syscall.h"

int getgroups(int count, gid_t list[])
{
	struct __creds creds = {
		.ngroup = (size_t)count,
		.groups = {
			.data = list,
			.length = count,
			.cap = count,
		},
	};
	getcreds(&creds);
	return creds.ngroup;
}
