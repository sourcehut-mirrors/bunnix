use boot;
use encoding::utf8;
use mb;
use strings;
use types::c;

// Static boot context
let ctx = boot::context { ... };

def CMDLINE_MAX: size = 4096;
let cmdline_buf: [CMDLINE_MAX]u8 = [0...];

def STATIC_MODS: size = 8;
let static_mods: [STATIC_MODS]boot::module = [
	boot::module { ... }...
];

let bootfb = boot::bootfb { ... };

fn bootctx_init(mb: *mb::multiboot) *boot::context = {
	const mods = mb.mods_addr: uintptr: *[*]mb::module;
	const mods = mods[..mb.mods_count];
	if (len(mods) > STATIC_MODS) {
		mods = mods[..STATIC_MODS];
	};

	// Memory map
	ctx.mmap = mmap;

	// Kernel command line
	const mb_cmdline = mods[0].string: uintptr: *const c::char;
	const cmdlen = c::strlen(mb_cmdline);
	assert(cmdlen <= CMDLINE_MAX, "Kernel command line exceeds maximum length");
	let cmdline = cmdline_buf[..cmdlen];
	cmdline[..] = (mb_cmdline: *[*]u8)[..cmdlen];

	match (strings::fromutf8(cmdline)) {
	case let s: str =>
		ctx.cmdline = s;
	case utf8::invalid =>
		abort("Kernel command line is not valid UTF-8");
	};

	// Boot modules
	ctx.mods = static_mods[..0];
	for (let i = 1z; i < len(mods); i += 1) {
		const mod = &mods[i];
		static append(ctx.mods, boot::module {
			phys = mod.start: uintptr,
			length = (mod.end - mod.start): size,
		});
	};

	// TODO: Framebuffer, if provided

	return &ctx;
};
