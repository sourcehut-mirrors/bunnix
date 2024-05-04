// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use io;
use os;
use rt;
use types::c;
use unix;

// Forks the current process, returning the [[process]] of the child (to the
// parent) and void (to the child), or an error.
export fn fork() (process | void | error) = {
	match (rt::fork()) {
	case let err: rt::errno  =>
		return errors::errno(err);
	case let i: rt::pid_t =>
		if (i == 0) {
			return;
		};
		return i: process;
	};
};

// Creates an anonymous pipe for use with [[addfile]]. Any data written to the
// second file may be read from the first file. The caller should close one or
// both of the file descriptors after they have transferred them to another
// process, and after they have finished using them themselves, if applicable.
//
// This function will abort the process if the system is unable to allocate the
// resources for a pipe. If you need to handle this error gracefully, you may
// call [[unix::pipe]] yourself, but this may reduce the portability of your
// software.
//
// To capture the standard output of a process:
//
// 	let pipe = exec::pipe();
// 	exec::addfile(&cmd, os::stdout_file, pipe.1);
// 	let proc = exec::start(&cmd)!;
// 	io::close(pipe.1)!;
//
// 	let data = io::drain(pipe.0)!;
// 	io::close(pipe.0)!;
// 	exec::wait(&proc)!;
//
// To write to the standard input of a process:
//
// 	let pipe = exec::pipe();
// 	exec::addfile(&cmd, os::stdin_file, pipe.0);
// 	let proc = exec::start(&cmd)!;
//
// 	io::writeall(data)!;
// 	io::close(pipe.1)!;
// 	io::close(pipe.0)!;
// 	exec::wait(&proc)!;
export fn pipe() (io::file, io::file) = {
	abort(); // TODO: Bunnix
};

fn open(path: str) (platform_cmd | error) = {
	// TODO: Bunnix: O_PATH

	let fd = match (rt::open(path, rt::O_RDONLY, 0u)) {
	case let fd: int =>
		yield fd;
	case let err: rt::errno =>
		return errors::errno(err);
	};

	// TODO: Bunnix: faccessat to check for +x, etc
	return fd;
};

fn platform_finish(cmd: *command) void = {
	rt::close(cmd.platform)!;
};

fn platform_exec(cmd: *command) error = {
	assert(len(cmd.files) == 0); // TODO
	assert(cmd.dir == ""); // TODO

	match (rt::fexecve(cmd.platform, cmd.argv, cmd.env)) {
	case let err: rt::errno =>
		return errors::errno(err);
	case void =>
		abort();
	};
};

fn platform_start(cmd: *command) (process | errors::error) = {
	// TODO: Make this more closely match +linux, handle errors

	match (rt::fork()) {
	case let err: rt::errno =>
		return errors::errno(err);
	case let pid: rt::pid_t =>
		if (pid == 0) {
			platform_exec(cmd): void;
			abort();
		};
		return pid;
	};
};
