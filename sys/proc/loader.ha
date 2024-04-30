use bytes;
use errors::{error, errno};
use format::elf;
use io;
use mman;

// Loads an ELF executable into a virtual memory manager, returning the entry
// point address.
export fn load(vmm: *mman::vmm, image: *io::file) (uintptr | error) = {
	mman::vmm_map(vmm);

	let buf: [size(elf::header64)]u8 = [0...];
	const n = io::read(image, buf) as size;
	assert(n == len(buf));
	const hdr = &buf[0]: *elf::header64;

	if (!bytes::equal(hdr.e_ident[..len(elf::MAGIC)], elf::MAGIC)) {
		return errno::NOEXEC;
	};
	if (hdr.e_type != elf::elf_type::EXEC) {
		return errno::NOEXEC;
	};
	if (hdr.e_machine != elf::elf_machine::X86_64) {
		return errno::NOEXEC;
	};

	for (let i = 0u16; i < hdr.e_phnum; i += 1) {
		const offs = hdr.e_phoff + i * hdr.e_phentsize;
		io::seek(image, offs: i64, io::whence::SET)?;

		let buf: [size(elf::phdr64)]u8 = [0...];
		const n = io::read(image, buf) as size;
		const phdr = &buf[0]: *elf::phdr64;
		if (phdr.p_type != elf::pt::LOAD) {
			continue;
		};

		phdr_load(vmm, image, phdr)?;
	};

	return hdr.e_entry: uintptr;
};

fn phdr_load(
	vmm: *mman::vmm,
	image: *io::file,
	phdr: *elf::phdr64,
) (void | error) = {
	// TODO: some more validation
	// - Is vaddr in the lower half?
	// - Is memsz and filesz reasonable?

	let prot = mman::prot::WRITE;
	if (phdr.p_flags & elf::pf::R != 0) {
		prot |= mman::prot::READ;
	};
	if (phdr.p_flags & elf::pf::X != 0) {
		prot |= mman::prot::EXEC;
	};

	assert(phdr.p_vaddr % 4096 == 0); // TODO
	let base = mman::mmap(vmm, 0,
		phdr.p_vaddr: uintptr,
		phdr.p_memsz,
		prot,
		mman::flag::ANON | mman::flag::USER)?;
	let data = base: *[*]u8;
	io::seek(image, phdr.p_offset: i64, io::whence::SET)?;
	io::readall(image, data[..phdr.p_filesz])?;

	if (phdr.p_flags & elf::pf::W == 0) {
		prot &= ~mman::prot::WRITE;
		mman::mprotect(vmm, phdr.p_vaddr: uintptr, phdr.p_memsz, prot)!;
	};
};
