// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

.section .text.rt.syscall
.global rt.syscall
rt.syscall:
	movq %rcx, %r10
	syscall
	ret
