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
#define ENAMETOOLONG	34
#define EADDRINUSE	35
#define EADDRNOTAVAIL	36
#define EAFNOSUPPORT	37
#define EALREADY	38
#define ECONNRESET	39
#define EDEADLK		40
#define EDESTADDRREQ	41
#define EDOM		42
#define EHOSTUNREACH	43
#define EINPROGRESS	44
#define EISCONN		45
#define ELOOP		46
#define EMFILE		47
#define EMSGSIZE	48
#define ENETDOWN	49
#define ENETRESET	50
#define ENETUNREACH	51
#define ENFILE		52
#define ENOBUFS		53
#define ENOPROTOOPT	54
#define ENOTCONN	55
#define ENOTSOCK	56
#define ENOTTY		57
#define EPIPE		58
#define EPROTONOSUPPORT	59
#define EPROTOTYPE	60
#define ESPIPE		61
#define ESRCH		62
#define EWOULDBLOCK	63
#define EXDEV		64
#define ECONNABORTED	65
#define ENOLCK		66
#define EOPNOTSUPP	67

// libc-internal errors
#define EILSEQ		256
#define ENOMSG		257

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

