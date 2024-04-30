// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

fn mman::kisreadable(addr: uintptr, length: size) bool;

// Details for a stack frame. Contents are architecture-specific.
export type stackframe = struct {
	fp: nullable *stackframe,
	ip: uintptr,
};

// Returns the next stack frame walking the stack.
export fn next(frame: stackframe) (stackframe | done) = {
	match (frame.fp) {
	case null =>
		return done;
	case let next: *stackframe =>
		if (!mman::kisreadable(next: uintptr, size(stackframe))) {
			return done;
		};
		if (next.fp == null) {
			return done;
		};
		return *next;
	};
};

// Return the program counter address for the given stack frame.
export fn frame_pc(frame: stackframe) uintptr = frame.ip;

// Implementation detail, constructs a synthetic stack frame.
fn mkframe(next: *stackframe, ip: uintptr) stackframe = {
	return stackframe {
		fp = next,
		ip = ip,
	};
};
