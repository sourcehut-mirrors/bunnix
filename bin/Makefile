all:

ROOT=../
include $(ROOT)mk/conf.mk

# /bin/*
include echo/Makefile
include init/Makefile

install-bin:
	for f in $^; \
	do install -Dm755 "$$f" $(DESTDIR)/bin; \
	done

install: install-bin

.PHONY: install install-bin

clean:
