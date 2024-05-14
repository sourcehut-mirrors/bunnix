#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include "stdio_impl.h"
#include "syscall.h"

FILE *popen(const char *cmd, const char *mode)
{
	int p[2], op;
	pid_t pid;
	FILE *f;

	if (*mode == 'r') {
		op = 0;
	} else if (*mode == 'w') {
		op = 1;
	} else {
		errno = EINVAL;
		return NULL;
	}

	if (pipe2(p, O_CLOEXEC)) {
		return NULL;
	}
	f = fdopen(p[op], mode);
	if (!f) {
		goto error;
	}

	pid = fork();
	if (pid < 0) {
		goto error;
	} else if (pid == 0) {
		close(p[op]);
		dup2(p[1-op], 1-op);
		execlp("sh", "sh", "-c", cmd, NULL);
	} else {
		if (!strchr(mode, 'e')) {
			fcntl(p[op], F_SETFD, 0);
		}
		close(p[1-op]);
		f->pipe_pid = pid;
		return f;
	}

error:
	close(p[0]);
	close(p[1]);
	if (f != NULL) {
		fclose(f);
	}
	return NULL;
}
