.text

.global arch.pause
arch.pause:
	pause
	ret

.global arch.idle
arch.idle:
	hlt
	jmp arch.idle
