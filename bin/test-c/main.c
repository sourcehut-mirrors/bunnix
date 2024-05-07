#define _POSIX_C_SOURCE
#include <assert.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	const char *lang = "C";
	printf("Hello userspace from %s! argc: %d\n", lang, argc);

	for (int i = 0; i < argc; ++i) {
		printf("argc[%d]: %s\n", i, argv[i]);
	}

	printf("opendir /\n");
	DIR *d = opendir("/");
	if (d == NULL) {
		perror("opendir");
		return 1;
	}
	for (struct dirent *ent; (ent = readdir(d)) != NULL;) {
		printf("/%s\n", ent->d_name);
	}

	closedir(d);

	printf("sleep\n");
	struct timespec ts = {
		.tv_sec = 1,
		.tv_nsec = 0,
	};
	nanosleep(&ts, NULL);

	printf("[orig] fork\n");
	pid_t pid = fork();
	if (pid < 0) {
		perror("fork");
		return 1;
	} else if (pid == 0) {
		printf("[child] execl /bin/echo Hello world!\n");
		printf("[child] sleep 1s\n");
		nanosleep(&ts, NULL);
		execl("/bin/echo", "/bin/echo", "Hello world!", NULL);
		return 0;
	}

	printf("[parent] child has pid %d\n", pid);
	printf("[parent] wait()\n");

	int status;
	waitpid(pid, &status, 0);

	assert(WIFEXITED(status));
	printf("[parent] child exited with status code %d\n",
			WEXITSTATUS(status));

	return 0;
}
