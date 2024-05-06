__asm__(
".text \n"
".global " START " \n"
START ": \n"
"	xor %rbp,%rbp \n"
"	mov %rsp,%rdi \n"
"	andq $-16,%rsp \n"
"	call " START "_c \n"
);
