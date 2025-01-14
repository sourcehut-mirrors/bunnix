use errors::{error, errno};
use io;
use poll;
use proc;

fn sys_poll(fds: *[*]pollfd, nfd: size, timeout: i64) (u64 | error) = {
	assert(timeout <= 0); // TODO

	validate_user_addr(fds, size(pollfd) * nfd, true)?;

	let fds = fds[..nfd];
	let ctx = poll::context {
		fd = alloc([], nfd)!,
		...
	};

	let events = 0u64;
	for (events == 0) {
		events = do_poll(&ctx, fds)?;

		if (timeout == 0 || events != 0) {
			break;
		};

		poll::wait(&ctx);
	};

	for (let i = 0z; i < len(fds); i += 1) {
		fds[i].revents = ctx.fd[i].revents;
	};

	poll::finish(&ctx);

	return events;
};

fn do_poll(ctx: *poll::context, fds: []pollfd) (u64 | error) = {
	poll::cancel(ctx);

	let events = 0u64;
	for (let fd &.. fds) {
		static append(ctx.fd, poll::pollfd {
			ctx = ctx,
			events = fd.events,
			...
		})!;
		let pfd = &ctx.fd[len(ctx.fd)-1];

		const file = match (validate_fd(fd.fd)) {
		case let fd: *proc::filedesc =>
			yield fd.file;
		case error =>
			pfd.revents = poll::POLLNVAL;
			events += 1;
			continue;
		};

		match (io::poll(file as *io::file, pfd)) {
		case let u: u64 =>
			events += u;
		case error =>
			pfd.revents = poll::POLLERR;
			events += 1;
			continue;
		};
	};

	return events;
};
