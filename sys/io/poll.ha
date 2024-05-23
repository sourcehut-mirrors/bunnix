export def POLLIN     = 0x001;
export def POLLPRI    = POLLIN;
export def POLLOUT    = 0x004;
export def POLLERR    = 0x008;
export def POLLHUP    = 0x010;
export def POLLNVAL   = 0x020;
export def POLLRDNORM = POLLIN;
export def POLLRDBAND = POLLIN;
export def POLLWRNORM = POLLOUT;
export def POLLWRBAND = POLLOUT;

// See [[poll::pollfd]]
export type pollfd = struct {
	events: uint,
	revents: uint,
};
