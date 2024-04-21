OUTPUT_FORMAT(binary)
ENTRY(_start)
 
SECTIONS
{
	. = 1M;
	_bootloader_start = .;

	_loader_code_start = .;
 
	.text : {
		*(.multiboot)
		*(.text.*)
	}

	.rodata : {
		*(.rodata.*)
	}

	.init_array : {
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP (*(.init_array))
		PROVIDE_HIDDEN (__init_array_end = .);
	}

	_loader_code_end = .;

	. = ALIGN(4K);

	_loader_data_start = .;
 
	.data : {
		*(.data.*)
	}

	.bss : {
		PROVIDE(bss_start = .);
		*(COMMON)
		*(.bss.*)
	}

	_loader_data_end = .;

	_loader_data_runtime_start = .;

	/* Reserve page tables */
       . = ALIGN(4K);
       pml4 = .;
       . += 512 * 8;
       pdpt = .;
       . += 512 * 8;
       ident_pd = .;
       . += 512 * 8 * 64;
       kernel_pd = .;
       . += 512 * 8;
       kernel_pt = .;
       . += 512 * 8;

	_loader_data_runtime_end = .;

	_bootloader_end = .;
}
