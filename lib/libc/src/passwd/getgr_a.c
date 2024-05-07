#include <byteswap.h>
#include <string.h>
#include <unistd.h>
#include "pwf.h"

static char *itoa(char *p, uint32_t x)
{
	// number of digits in a uint32_t + NUL
	p += 11;
	*--p = 0;
	do {
		*--p = '0' + x % 10;
		x /= 10;
	} while (x);
	return p;
}

int __getgr_a(const char *name, gid_t gid, struct group *gr, char **buf, size_t *size, char ***mem, size_t *nmem, struct group **res)
{
	FILE *f;
	int rv = 0;

	*res = 0;

	f = fopen("/etc/group", "rbe");
	if (!f) {
		rv = errno;
		goto done;
	}

	while (!(rv = __getgrent_a(f, gr, buf, size, mem, nmem, res)) && *res) {
		if (name && !strcmp(name, (*res)->gr_name)
		|| !name && (*res)->gr_gid == gid) {
			break;
		}
	}
	fclose(f);

done:
	if (rv) errno = rv;
	return rv;
}
