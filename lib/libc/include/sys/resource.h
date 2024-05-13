#ifndef	_SYS_RESOURCE_H
#define	_SYS_RESOURCE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <features.h>
#include <sys/time.h>

#define __NEED_id_t

#ifdef _GNU_SOURCE
#define __NEED_pid_t
#endif

#include <bits/alltypes.h>

typedef unsigned long rlim_t;

struct rlimit {
	rlim_t rlim_cur;
	rlim_t rlim_max;
};

struct rusage {
	struct timeval ru_utime;
	struct timeval ru_stime;
};

int getrlimit (int, struct rlimit *);
int setrlimit (int, const struct rlimit *);
int getrusage (int, struct rusage *);

int getpriority (int, id_t);
int setpriority (int, id_t, int);

#define PRIO_MIN (-20)
#define PRIO_MAX 20

#define PRIO_PROCESS 0
#define PRIO_PGRP    1
#define PRIO_USER    2

#define RUSAGE_SELF     0
#define RUSAGE_CHILDREN (-1)
#define RUSAGE_THREAD   1

#define RLIM_INFINITY (~0ULL)
#define RLIM_SAVED_CUR RLIM_INFINITY
#define RLIM_SAVED_MAX RLIM_INFINITY

#define RLIMIT_CPU     0
#define RLIMIT_FSIZE   1
#define RLIMIT_DATA    2
#define RLIMIT_STACK   3
#define RLIMIT_CORE    4
#define RLIMIT_NOFILE  5
#define RLIMIT_AS      6
#define RLIMIT_NLIMITS 6

#define RLIM_NLIMITS RLIMIT_NLIMITS

#ifdef __cplusplus
}
#endif

#endif
