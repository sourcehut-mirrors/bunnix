LOLCAT=$(ROOT)/vendor/lolcat
LOLCAT_SOURCES=$(call rwildcard,$(LOLCAT),*.c *.h)

clean-lolcat:
	make -C $(LOLCAT) clean
	rm -f lolcat

.PHONY: clean-lolcat

clean: clean-lolcat

lolcat: $(LOLCAT)/lolcat
	cp $(LOLCAT)/lolcat lolcat

$(LOLCAT)/lolcat: $(LOCAT_SOURCES)
	make -C $(LOLCAT) CC=$(CC)

install-bin: lolcat
