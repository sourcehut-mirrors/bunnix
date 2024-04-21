OUTPUT_FORMAT(binary)
ENTRY(_start)
 
SECTIONS
{
	. = 1M;
	phys = .;
 
	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.multiboot)
		*(.text.*)
	}
 
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata.*)
	}
 
	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data.*)
	}

	.init_array :
        {
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP (*(.init_array))
		PROVIDE_HIDDEN (__init_array_end = .);
	}
 
	.bss BLOCK(4K) : ALIGN(4K)
	{
		PROVIDE(bss_start = .);
		*(COMMON)
		*(.bss.*)
	}

	end = .;
}
