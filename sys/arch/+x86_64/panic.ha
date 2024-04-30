// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use debug;
use log;
use rt;

def MAX_FRAMES_TOP: size = 16z;
def MAX_FRAMES_BOTTOM: size = 16z;
def MAX_FRAMES: size = MAX_FRAMES_TOP + MAX_FRAMES_BOTTOM;

// Logs the contents of a [[context]].
export fn logctx(ctx: *context) void = {
	log::printfln("rax {:x} rcx {:x} rdx {:x} rbx {:x}",
		ctx.rax, ctx.rcx, ctx.rdx, ctx.rbx);
	log::printfln("rbp {:x} rsi {:x} rdi {:x} r8 {:x}",
		ctx.rbp, ctx.rsi, ctx.rdi, ctx.r8);
	log::printfln("r9 {:x} r10 {:x} r11 {:x} r12 {:x}",
		ctx.r9, ctx.r10, ctx.r11, ctx.r12);
	log::printfln("r13 {:x} r14 {:x} r15 {:x} rip {:x}",
		ctx.r13, ctx.r14, ctx.r15, ctx.rip);
	log::printfln("cs {:x} ss {:x} fs {:x}", ctx.cs, ctx.ss, ctx.fs);
	log::printfln("rsp {:x} rflags {:x} intno {:x} err {:x}",
		ctx.rsp, ctx.rflags, ctx.intno, ctx.errcode);

	log::println("\nBacktrace:");
	let fp = debug::stackframe {
		fp = ctx.rbp: uintptr: nullable *debug::stackframe,
		ip = ctx.rip: uintptr,
	};

	let orig = fp;
	let nframe = 1z;
	for (true; nframe += 1) {
		match (debug::next(fp)) {
		case let next: debug::stackframe =>
			fp = next;
		case done => break;
		};
	};
	fp = orig;

	static let seen: [MAX_FRAMES]uintptr = [0: uintptr...];
	let seen = seen[..0];

	for (let i = 0z; i < nframe; i += 1) {
		if (i < MAX_FRAMES_TOP || i > nframe - MAX_FRAMES_BOTTOM) {
			log::printfln("\t{:x}", debug::frame_pc(fp));
		};
		if (i == MAX_FRAMES_TOP && nframe > MAX_FRAMES) {
			log::printfln("\t({} additional frames omitted)",
				nframe - MAX_FRAMES): void;
		};

		match (debug::next(fp)) {
		case let next: debug::stackframe =>
			fp = next;
		case done =>
			break;
		};
	};
};

// Kernel panic, print panic details to log and halt kernel.
export fn panic(reason: str, ctx: *context) never = {
	log::printfln("!! panic !! {}", reason);
	logctx(ctx);
	log::println("System halted.");
	rt::halt();
};
