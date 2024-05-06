#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include "syscall.h"

int __prep_execve(struct __exec_options *opts, char *const argv[], char *const envp[])
{
	size_t narg = 0;
	for (; argv[narg]; ++narg) ;
	size_t nenv = 0;
	for (; envp[nenv]; ++nenv) ;

	__slice_t args = {
		.data = narg ? malloc(sizeof(__string_t) * narg) : NULL,
		.length = narg,
		.cap = narg,
	};
	if (narg && !args.data) {
		errno = ENOMEM;
		return -1;
	}

	__slice_t env = {
		.data = nenv ? malloc(sizeof(__string_t) * nenv) : NULL,
		.length = nenv,
		.cap = nenv,
	};
	if (nenv && !env.data) {
		errno = ENOMEM;
		free((void *)args.data);
		return -1;
	}

	__string_t *arg_slice = (__string_t *)args.data;
	for (size_t i = 0; argv[i]; ++i) {
		arg_slice[i] = sys_string(argv[i], strlen(argv[i]));
	}

	__string_t *env_slice = (__string_t *)env.data;
	for (size_t i = 0; envp[i]; ++i) {
		env_slice[i] = sys_string(envp[i], strlen(envp[i]));
	}

	opts->args = args;
	opts->environ = env;

	return 0;
}

int execve(const char *path, char *const argv[], char *const envp[])
{
	struct __exec_options opts = {
		.path = sys_string(path, strlen(path)),
		0
	};
	int ret = __prep_execve(&opts, argv, envp);
	if (ret != 0) {
		return ret;
	}
	return syscall(SYS_execve, &opts);
}

int fexecve(int fd, char *const argv[], char *const envp[])
{
	struct __exec_options opts = {
		.flags = EXEC_FEXECVE,
		.fd = fd,
		0
	};
	int ret = __prep_execve(&opts, argv, envp);
	if (ret != 0) {
		return ret;
	}
	return syscall(SYS_execve, &opts);
}
