#define _POSIX_C_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int main() {
	const char *lang = "C";
	printf("Hello userspace from %s!\n", lang);

	printf("Open /usr/include/stdio.h\n");
	FILE *f = fopen("/usr/include/stdio.h", "r");
	if (f == NULL) {
		perror("fopen");
		return 1;
	};

	int fd = fileno(f);
	printf("FILE %p w/fd %d\n", (void *)f, fd);

	struct stat st;
	int r = fstat(fd, &st);
	if (r != 0) {
		perror("fstat");
	};
	printf("fstat: mode %o owner %d/%d\n", st.st_mode, st.st_uid, st.st_gid);

	char buf[256];
	size_t n = fread(buf, 1, sizeof(buf) - 1, f);
	printf("fread got %zu bytes\n", n);
	buf[n] = 0;
	printf("First 256 bytes: %s\n", buf);

	fclose(f);
	return 0;
}
