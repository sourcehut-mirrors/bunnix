ROOT=../
include $(ROOT)mk/conf.mk

install-libc:
	make -C libc install DESTDIR=../$(DESTDIR)

install: install-libc

clean-libc:
	make -C libc clean

clean: clean-libc

.PHONY: install install-libc clean clean-libc
