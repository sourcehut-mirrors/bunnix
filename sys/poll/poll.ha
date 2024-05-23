use io;
use sched;

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
export def REVENT_MASK = POLLERR | POLLNVAL | POLLHUP;

// State for a pending poll operation.
export type context = struct {
	wq: sched::wq_head,
	fd: []pollfd,
};

// State for a pending poll event for a given event source.
export type pollfd = struct {
	io::pollfd,
	ctx: *context,
	next: nullable *pollfd,
	prev: nullable *nullable *pollfd,
};

// Event source for poll operations (i.e. a file).
export type event_source = struct {
	head: nullable *pollfd,
};

// Registers a poll event with its event source.
export fn register(src: *event_source, link: *io::pollfd) void = {
	let link = link: *pollfd;
	assert(link.prev == null && link.next == null);

	match (src.head) {
	case null =>
		src.head = link;
		link.prev = &src.head;
	case let next: *pollfd =>
		next.prev = &link.next;
		link.next = next;
		link.prev = &src.head;
		src.head = link;
	};
};

// Signals all eligible poll events on this event source.
export fn signal(src: *event_source, revents: uint) void = {
	let next: nullable *pollfd = src.head;
	for (let link = next; link != null; link = next) {
		let link = link: *pollfd;
		next = link.next;
		if (link.events & revents == 0) {
			const mask = link.events | REVENT_MASK;
			link.revents = revents & mask;
			continue;
		};
		const ctx = link.ctx;
		sched::wake(&ctx.wq);
		pollfd_unlink(link);
	};
};

// Waits for poll events on this poll [[context]].
export fn wait(ctx: *context) void = {
	let link = sched::wq_link { ... };
	sched::wait(&ctx.wq, &link);
};

// Cancels pending poll events for this [[context]].
export fn cancel(ctx: *context) void = {
	for (let fd &.. ctx.fd) {
		pollfd_unlink(fd);
	};
	ctx.fd = ctx.fd[..0];
};

// Cancels pending poll events and frees the pollfd list.
export fn finish(ctx: *context) void = {
	cancel(ctx);
	free(ctx.fd);
};

fn pollfd_unlink(link: *pollfd) void = {
	if (link.prev == null) {
		assert(link.next == null);
		return;
	};

	let prev = link.prev as *nullable *pollfd;
	*prev = link.next;

	match (link.next) {
	case let next: *pollfd =>
		next.prev = prev;
	case null => void;
	};

	link.prev = null;
	link.next = null;
};
