use arch::x86_64;
use arch::x86_64::{PAGESIZE, UPAGESIZE, pte};
use boot;
use bytes;
use format::elf;
use rt;

fn load(image: *elf::header64) *kentry = {
	assert(bytes::equal(image.e_ident[..len(elf::MAGIC)], elf::MAGIC),
		"Kernel is not a valid ELF image");
	assert(image.e_type == elf::elf_type::EXEC,
		"Kernel is not an executable");
	assert(image.e_machine == elf::elf_machine::X86_64,
		"Kernel is not built for an x86_64 system");

	const base = image: uintptr;
	const entry = image.e_entry: uintptr: *kentry;
	const phdr = (base + image.e_phoff: uintptr): *[*]u8;
	load_phdrs(image, phdr);

	return entry;
};

fn load_phdrs(image: *elf::header64, phdrs: *[*]u8) void = {
	const base = image: uintptr;

	// Measure kernel memory requirements
	let brksz = 0z;
	for (let i = 0u16; i < image.e_phnum; i += 1) {
		const phdr = &phdrs[i * image.e_phentsize]: *elf::phdr64;
		if (phdr.p_type != elf::pt::LOAD) {
			continue;
		};
		if (brksz % PAGESIZE != 0) {
			brksz += PAGESIZE - (brksz % PAGESIZE);
		};
		brksz += phdr.p_memsz;
	};

	// Reserve memory
	let brk = init_brk(brksz);
	assert(brk % UPAGESIZE == 0);

	// And load the kernel
	for (let i = 0u16; i < image.e_phnum; i += 1) {
		const phdr = &phdrs[i * image.e_phentsize]: *elf::phdr64;
		if (phdr.p_type != elf::pt::LOAD) {
			continue;
		};
		if (brk % UPAGESIZE != 0) {
			brk += UPAGESIZE - (brk % UPAGESIZE);
		};

		const src = (base + phdr.p_offset: uintptr): *[*]u8;
		const src = src[..phdr.p_filesz];

		let dest = (brk: *[*]u8)[..phdr.p_memsz];
		bytes::zero(dest);
		dest[..phdr.p_filesz] = src[..];

		let ptf = 0: pte;
		// TODO: Consider NX if available on target
		if (phdr.p_flags & elf::pf::W != 0) {
			ptf |= pte::W;
		};

		let virt = phdr.p_vaddr: uintptr;
		const max = (phdr.p_vaddr + phdr.p_memsz): uintptr;
		for (virt < max; virt += UPAGESIZE) {
			kmmap(virt, brk, ptf);
			brk += UPAGESIZE;
		};
	};
};

fn init_brk(sz: size) uintptr = {
	let npage = sz / PAGESIZE;
	if (sz % PAGESIZE != 0) {
		npage += 1;
	};

	for (let i = 0z; i < len(mmap); i += 1) {
		const entry = mmap[i];
		if (entry.mtype != boot::mtype::CONVENTIONAL) {
			continue;
		};
		if (entry.pages < npage) {
			continue;
		};
		if (entry.phys == 0) {
			continue;
		};

		mmap[i] = boot::marea {
			phys = entry.phys,
			pages = npage,
			mtype = boot::mtype::KERNEL_IMAGE,
		};
		if (entry.pages != npage) {
			static insert(mmap[i+1], boot::marea {
				phys = entry.phys + npage: uintptr * UPAGESIZE,
				pages = entry.pages - npage,
				mtype = boot::mtype::CONVENTIONAL,
			});
		};

		return entry.phys;
	};

	abort("Insufficient memory to load kernel");
};
