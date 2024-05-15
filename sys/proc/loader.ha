use arch;
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

	let brk = 0: uintptr;
	for (let i = 0u16; i < hdr.e_phnum; i += 1) {
		const offs = hdr.e_phoff + i * hdr.e_phentsize;
		io::seek(image, offs: i64, io::whence::SET)?;

		let buf: [size(elf::phdr64)]u8 = [0...];
		const n = io::read(image, buf) as size;
		const phdr = &buf[0]: *elf::phdr64;
		if (phdr.p_type != elf::pt::LOAD) {
			continue;
		};

		phdr_load(vmm, image, phdr, &brk)?;
	};

	if (brk % arch::PAGESIZE != 0) {
		brk += arch::PAGESIZE - brk % arch::PAGESIZE;
	};

	vmm.brk = brk;

	return hdr.e_entry: uintptr;
};

fn phdr_load(
	vmm: *mman::vmm,
	image: *io::file,
	phdr: *elf::phdr64,
	brk: *uintptr,
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

	let p_filesz = phdr.p_filesz: size;
	let p_memsz = phdr.p_memsz: size;
	let p_vaddr = phdr.p_vaddr: uintptr;
	let p_offs = 0z;

	if (p_vaddr & arch::PAGEMASK != 0) {
		p_offs = (p_vaddr & arch::PAGEMASK): size;
		p_vaddr &= ~arch::PAGEMASK;
		p_memsz += p_offs;
	};

	let base = mman::mmap(vmm, 0, p_vaddr, p_memsz, prot,
		mman::flag::ANON | mman::flag::USER)?;
	let data = base: *[*]u8;
	io::seek(image, phdr.p_offset: i64, io::whence::SET)?;
	io::readall(image, data[p_offs..p_offs+p_filesz])?;

	if (phdr.p_flags & elf::pf::W == 0) {
		prot &= ~mman::prot::WRITE;
		mman::mprotect(vmm, p_vaddr: uintptr, p_memsz, prot)!;
	};

	const max = (p_vaddr + p_memsz): uintptr;
	if (max > *brk) {
		*brk = max;
	};
};
