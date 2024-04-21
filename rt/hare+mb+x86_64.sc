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
	_bootloader_end = .;
}
