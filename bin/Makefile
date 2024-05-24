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

install-man:
	mkdir -p $(DESTDIR)/usr/share/man/man1
	for f in $^; \
	do install -Dm644 "$$f" $(DESTDIR)/usr/share/man/man1; \
	done

install: install-bin install-man

clean:

.PHONY: install install-bin install-man clean
