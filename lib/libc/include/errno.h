#ifndef	_ERRNO_H
#define _ERRNO_H

#ifdef __cplusplus
extern "C" {
#endif

#include <features.h>

#define ENOMEM		1
#define EOVERFLOW	2
#define EUNDERFLOW	3
#define EINVAL		4
#define EEXIST		5
#define ENOTSUP		6
#define ENOENT		7
#define EBUSY		8
#define EPERM		9
#define EIO		10
#define ENXIO		11
#define E2BIG		12
#define EACCES		13
#define EFAULT		14
#define ENODEV		15
#define ENOTDIR		16
#define EISDIR		17
#define EFBIG		18
#define ENOSPC		19
#define EROFS		20
#define EMLINK		21
#define ERANGE		22
#define ENOTEMPTY	23
#define ENODATA		24
#define ENOEXEC		25
#define ENOSYS		26
#define EBADF		27
#define ECONNREFUSED	28
#define ECANCELED	29
#define ETIMEDOUT	30
#define EINTR		31
#define EAGAIN		32
#define ECHILD		33

// libc-internal errors
#define EILSEQ		256

#ifdef __GNUC__
__attribute__((const))
#endif
int *__errno_location(void);
#define errno (*__errno_location())

#ifdef _GNU_SOURCE
extern char *program_invocation_short_name, *program_invocation_name;
#endif

#ifdef __cplusplus
}
#endif

#endif

