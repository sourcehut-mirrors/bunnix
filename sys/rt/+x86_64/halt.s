.text
.globl rt.halt
rt.halt:
	cli
	hlt
	jmp rt.halt
