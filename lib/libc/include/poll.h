#ifndef	_POLL_H
#define	_POLL_H

#ifdef __cplusplus
extern "C" {
#endif

#include <features.h>

#define POLLIN     0x001
#define POLLPRI    POLLIN
#define POLLOUT    0x004
#define POLLERR    0x008
#define POLLHUP    0x010
#define POLLNVAL   0x020
#define POLLRDNORM POLLIN
#define POLLRDBAND POLLIN
#ifndef POLLWRNORM
#define POLLWRNORM POLLOUT
#define POLLWRBAND POLLOUT
#endif

typedef unsigned long nfds_t;

struct pollfd {
	int fd;
	unsigned int events;
	unsigned int revents;
};

int poll(struct pollfd *, nfds_t, int);

#ifdef __cplusplus
}
#endif

#endif
