#include <signal.h>
#include <string.h>
#include "locale_impl.h"

static const char map[] = {
	[SIGHUP]    = 1,
	[SIGINT]    = 2,
	[SIGQUIT]   = 3,
	[SIGILL]    = 4,
	[SIGTRAP]   = 5,
	[SIGABRT]   = 6,
	[SIGBUS]    = 7,
	[SIGFPE]    = 8,
	[SIGKILL]   = 9,
	[SIGUSR1]   = 10,
	[SIGSEGV]   = 11,
	[SIGUSR2]   = 12,
	[SIGPIPE]   = 13,
	[SIGALRM]   = 14,
	[SIGTERM]   = 15,
	[SIGCHLD]   = 17,
	[SIGCONT]   = 18,
	[SIGSTOP]   = 19,
	[SIGTSTP]   = 20,
	[SIGTTIN]   = 21,
	[SIGTTOU]   = 22,
	[SIGURG]    = 23,
	[SIGXCPU]   = 24,
	[SIGXFSZ]   = 25,
	[SIGVTALRM] = 26,
	[SIGPROF]   = 27,
	[SIGSYS]    = 31
};

#define sigmap(x) ((x) >= sizeof map ? (x) : map[(x)])

static const char strings[] =
	"Unknown signal\0"
	"Hangup\0"
	"Interrupt\0"
	"Quit\0"
	"Illegal instruction\0"
	"Trace/breakpoint trap\0"
	"Aborted\0"
	"Bus error\0"
	"Arithmetic exception\0"
	"Killed\0"
	"User defined signal 1\0"
	"Segmentation fault\0"
	"User defined signal 2\0"
	"Broken pipe\0"
	"Alarm clock\0"
	"Terminated\0"
	"Child process status\0"
	"Continued\0"
	"Stopped (signal)\0"
	"Stopped\0"
	"Stopped (tty input)\0"
	"Stopped (tty output)\0"
	"Urgent I/O condition\0"
	"CPU time limit exceeded\0"
	"File size limit exceeded\0"
	"Virtual timer expired\0"
	"Profiling timer expired\0"
	"Window changed\0"
	"I/O possible\0"
	"Power failure\0"
	"Bad system call\0";

char *strsignal(int signum)
{
	const char *s = strings;

	signum = sigmap(signum);
	if (signum - 1U >= _NSIG-1) signum = 0;

	for (; signum--; s++) for (; *s; s++);

	return (char *)LCTRANS_CUR(s);
}
