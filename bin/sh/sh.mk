DASH=$(ROOT)/vendor/dash

$(DASH)/Makefile: $(DASH)/configure
	cd $(DASH) && ./configure --target=$(TRIPLET)

DASH_SOURCES=$(call rwildcard,$(DASH)/src,*.c *.h)

$(DASH)/src/sh: $(DASH_SOURCES) $(DASH)/Makefile
	cd $(DASH) && make
	cd $(DASH) && cp src/dash src/sh

install-bin: $(DASH)/src/sh

clean-dash:
	cd $(DASH) && make clean

clean: clean-dash
