all:

ROOT=../
include $(ROOT)mk/conf.mk

MAN1=\
     man/man1/intro.1

all: $(MAN1)

man/man1/%.1: man/man1/%.1.scd
	$(SCDOC) < $^ > $@

install: $(MAN1)
	for doc in $(MAN1); do\
		install -Dm644 $$doc $(DESTDIR)/usr/share/man/man1/; \
	done
