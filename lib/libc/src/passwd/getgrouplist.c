#define _GNU_SOURCE
#include "pwf.h"
#include <grp.h>
#include <string.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <byteswap.h>
#include <errno.h>

int getgrouplist(const char *user, gid_t gid, gid_t *groups, int *ngroups)
{
	int rv, nlim, ret = -1;
	ssize_t i, n = 1;
	struct group gr;
	struct group *res;
	FILE *f;
	char *buf = 0;
	char **mem = 0;
	size_t nmem = 0;
	size_t size;
	nlim = *ngroups;
	if (nlim >= 1) *groups++ = gid;

	f = fopen("/etc/group", "rbe");
	if (!f && errno != ENOENT && errno != ENOTDIR)
		goto cleanup;

	if (f) {
		while (!(rv = __getgrent_a(f, &gr, &buf, &size, &mem, &nmem, &res)) && res) {
			for (i=0; gr.gr_mem[i] && strcmp(user, gr.gr_mem[i]); i++);
			if (!gr.gr_mem[i]) continue;
			if (++n <= nlim) *groups++ = gr.gr_gid;
		}
		if (rv) {
			errno = rv;
			goto cleanup;
		}
	}

	ret = n > nlim ? -1 : n;
	*ngroups = n;

cleanup:
	if (f) fclose(f);
	free(buf);
	free(mem);
	return ret;
}
