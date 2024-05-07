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

int __getpw_a(const char *name, uid_t uid, struct passwd *pw, char **buf, size_t *size, struct passwd **res)
{
	FILE *f;
	int rv = 0;

	*res = 0;

	f = fopen("/etc/passwd", "rbe");
	if (!f) {
		rv = errno;
		goto done;
	}

	while (!(rv = __getpwent_a(f, pw, buf, size, res)) && *res) {
		if (name && !strcmp(name, (*res)->pw_name)
		|| !name && (*res)->pw_uid == uid)
			break;
	}
	fclose(f);

done:
	if (rv) errno = rv;
	return rv;
}
