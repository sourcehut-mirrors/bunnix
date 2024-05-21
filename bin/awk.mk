LOK=$(ROOT)/vendor/lok
LOK_SOURCES=$(call rwildcard,$(LOK),*.c *.h)

clean-lok:
	make -C $(LOK) clean
	rm -f awk

.PHONY: clean-lok

clean: clean-lok

awk: $(LOK)/awk
	cp $(LOK)/awk awk

$(LOK)/awk: $(LOK_SOURCES)
	make -C $(LOK) CC=$(CC)

install-bin: awk
