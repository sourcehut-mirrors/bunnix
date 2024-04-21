// Adapted from Toaruos
// License: NCSA
// (c) 2021 K. Lange <klange@toaruos.org>
.text
.global arch.measuretsc
arch.measuretsc:
	// Disable and set gate for channel 2
	inb $0x61, %al
	andb $0xDD, %al
	orb $0x01, %al
	outb %al, $0x61
	// Configure channel 2 to one-shot
	movb $0xB2, %al
	outb %al, $0x43
	// Set deadline to 11931 (0x2E9B) ticks (10 milliseconds at 1.1931 MHz)
	movb $0x9B, %al
	outb %al, $0x42
	inb $0x60, %al

	movb $0x2E, %al
	outb %al, $0x42

	// Enable timer and pulse high
	inb $0x61, %al
	andb $0xDE, %al
	outb %al, $0x61
	orb $0x01, %al
	outb %al, $0x61
	// Read TSC
	rdtsc
	movl %eax, (%rdi)
	movl %edx, 4(%rdi)

	inb $0x61, %al
	andb $0x20, %al
	jz 2f

	// Loop until the output goes low
1:
	inb $0x61, %al
	andb $0x20, %al
	jnz 1b
	rdtsc
	jmp 3f
2:
	// Loop until high
	inb $0x61, %al
	andb $0x20, %al
	jz 2b
	rdtsc
3:
	movl %eax, 8(%rdi)
	movl %edx, 12(%rdi)
	ret

.global arch.rdtsc
arch.rdtsc:
	xorq %rax, %rax
	rdtsc
	shl $32, %rdx
	orq %rdx, %rax
	ret
