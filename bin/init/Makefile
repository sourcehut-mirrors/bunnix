INIT_SOURCES=$(wildcard,init,*.ha)
INIT_SOURCES+=$(HARE_SOURCES)

init/init: $(INIT_SOURCES)
	$(HAREBUILD) -o $@ init/

install-bin: init/init
