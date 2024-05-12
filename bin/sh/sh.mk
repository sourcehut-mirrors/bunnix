DASH=$(ROOT)/vendor/dash

$(DASH)/Makefile: $(DASH)/configure $(SYSROOT)/usr/lib/libc.a
	cd $(DASH) && ./configure --host=$(TRIPLET) CFLAGS="-g"

DASH_SOURCES=$(call rwildcard,$(DASH)/src,*.c *.h)

$(DASH)/src/sh: $(DASH_SOURCES) $(DASH)/Makefile
	cd $(DASH) && make V=1
	cd $(DASH) && cp src/dash src/sh

install-bin: $(DASH)/src/sh

clean-dash:
	cd $(DASH) && make distclean || true >/dev/null 2>&1
	cd $(DASH) && rm -f src/sh

clean: clean-dash
