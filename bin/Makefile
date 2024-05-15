all:

ROOT=../
include $(ROOT)mk/conf.mk

include awk.mk
include sh.mk
include sbase.mk

install-bin:
	for f in $^; \
	do install -Dm755 "$$f" $(DESTDIR)/bin; \
	done

install: install-bin

clean:

.PHONY: install install-bin clean
