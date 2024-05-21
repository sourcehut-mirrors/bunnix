all:

ROOT=../
include $(ROOT)mk/conf.mk

include awk.mk
include lolcat.mk
include sbase.mk
include sh.mk

install-bin:
	for f in $^; \
	do install -Dm755 "$$f" $(DESTDIR)/bin; \
	done

install: install-bin

clean:

.PHONY: install install-bin clean
