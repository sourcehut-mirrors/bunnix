OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)
PHDRS {
	text PT_LOAD;
	data PT_LOAD;
}

SECTIONS {
	/* 0xFFFFFF8000000000 - 0xFFFFFF9000000000 (64 GiB)	Identity map */
	/* 0xFFFFFFFFC0000000 - _kernel_end			Kernel image */
	. = 0xFFFFFF8000000000;
	_ident_start = .;

	. = 0xFFFFFFFFC0000000;
	_kernel_start = .;

	. = ALIGN(4096);
	.text : {
		KEEP (*(.text))
		*(.text.*)
	} :text

	. = ALIGN(4096);
	.data : {
		KEEP (*(.data))
		*(.data.*)
	} :data

	. = ALIGN(4096);
	.bss : {
		KEEP (*(.bss))
		*(.bss.*)

		. = ALIGN(4096);
		_kernel_stack_bottom = .;
		. += 16384;
		_kernel_stack_top = .;
	} :data

	_kernel_end = .;
}
