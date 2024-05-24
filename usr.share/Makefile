all:

ROOT=../
include $(ROOT)mk/conf.mk

MAN1=\
     man/man1/intro.1

MAN7=\
     man/man7/boot.7

all: $(MAN1)

man/man1/%.1: man/man1/%.1.scd
	$(SCDOC) < $^ > $@
man/man7/%.7: man/man7/%.7.scd
	$(SCDOC) < $^ > $@

install: $(MAN1) $(MAN7)
	for doc in $(MAN1); do\
		install -Dm644 $$doc $(DESTDIR)/usr/share/man/man1/; \
	done
	for doc in $(MAN7); do\
		install -Dm644 $$doc $(DESTDIR)/usr/share/man/man7/; \
	done
