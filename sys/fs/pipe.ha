use errors::{error, errno};
use io;
use sched;

// TODO: This should be configurable
def PIPE_BUF: size = 65536;

export type pipe = struct {
	rd: nullable *pipe_file,
	wr: nullable *pipe_file,
	buffer: []u8,
	avail: []u8,
};

export type pipe_file = struct {
	io::file,
	pipe: *pipe,
	wq: sched::wq_head,
};

const pipe_rd_impl = io::vtable {
	read = &pipe_file_read,
	finish = &pipe_file_finish,
	...
};

const pipe_wr_impl = io::vtable {
	write = &pipe_file_write,
	finish = &pipe_file_finish,
	...
};

// Makes a new pipe.
export fn mkpipe() ((*io::file, *io::file) | error) = {
	let rd = alloc(pipe_file {
		vtable = &pipe_rd_impl,
		pipe = null: *pipe,
		...
	});
	let wr = alloc(pipe_file {
		vtable = &pipe_wr_impl,
		pipe = null: *pipe,
		...
	});
	let pipe = alloc(pipe {
		rd = rd,
		wr = wr,
		buffer = alloc([0...], PIPE_BUF),
		...
	});
	rd.pipe = pipe;
	wr.pipe = pipe;
	pipe.avail = pipe.buffer[..0];
	return (rd, wr);
};

fn pipe_file_read(f: *io::file, buf: []u8) (size | io::EOF | error) = {
	const file = f: *pipe_file;
	const pipe = file.pipe;

	let link = sched::wq_link { ... };
	for (true) {
		if (pipe.wr == null && len(pipe.avail) == 0) {
			return io::EOF;
		};

		if (len(pipe.avail) == 0) {
			sched::wait(&file.wq, &link);
		} else {
			break;
		};
	};

	let copy = len(pipe.avail);
	if (copy > len(buf)) {
		copy = len(buf);
	};
	buf[..copy] = pipe.avail[..copy];
	static delete(pipe.avail[..copy]);

	// Wake writers
	if (pipe.wr != null) {
		const wr = pipe.wr as *pipe_file;
		sched::wake(&wr.wq);
	};

	return copy;
};

fn pipe_file_write(f: *io::file, buf: const []u8) (size | error) = {
	const file = f: *pipe_file;
	const pipe = file.pipe;

	let link = sched::wq_link { ... };
	for (true) {
		if (pipe.rd == null) {
			// TODO: Send SIGPIPE
			return errno::PIPE: error;
		};

		if (len(pipe.avail) == len(pipe.buffer)) {
			sched::wait(&file.wq, &link);
		} else {
			break;
		};
	};

	const remain = len(pipe.buffer) - len(pipe.avail);
	let copy = remain;
	if (len(buf) < copy) {
		copy = len(buf);
	};
	static append(pipe.avail, buf[..copy]...);

	// Wake readers
	const rd = pipe.rd as *pipe_file;
	sched::wake(&rd.wq);

	return copy;
};

fn pipe_file_finish(f: *io::file) void = {
	const file = f: *pipe_file;
	const pipe = file.pipe;

	assert(file == pipe.rd || file == pipe.wr);
	const other = if (file == pipe.rd) {
		free(pipe.rd);
		pipe.rd = null;
		yield pipe.wr;
	} else {
		free(pipe.wr);
		pipe.wr = null;
		yield pipe.rd;
	};

	// Wake other side
	match (other) {
	case let other: *pipe_file =>
		sched::wake(&other.wq);
	case null => void;
	};

	if (pipe.rd == null && pipe.wr == null) {
		free(pipe.buffer);
		free(pipe);
	};
};
