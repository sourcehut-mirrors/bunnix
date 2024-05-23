LOK=$(ROOT)/vendor/lok
LOK_SOURCES=$(call rwildcard,$(LOK),*.c *.h)

clean-lok:
	cd $(LOK) && rm -f awk ytab.h ytab.c proctab.c maketab
	rm -f awk

.PHONY: clean-lok

clean: clean-lok

awk: $(LOK)/awk
	cp $(LOK)/awk awk

$(LOK)/awk: $(LOK_SOURCES)
	make -C $(LOK) CC=$(CC) HOSTCC=$(HOSTCC)

install-bin: awk
