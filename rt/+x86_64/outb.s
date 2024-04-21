.global rt.outb
rt.outb:
	mov %di, %dx
	mov %sil, %al
	outb %al, %dx
	ret
