all:

ROOT=../
include $(ROOT)mk/conf.mk

install-bin:
	for f in $*; \
	do install -Dm755 "$$f" $(DESTDIR)/bin; \
	done

install: install-bin

.PHONY: install install-bin
