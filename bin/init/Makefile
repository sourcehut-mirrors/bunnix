INIT_SOURCES=$(wildcard,init,*.ha)
INIT_SOURCES+=$(HARE_SOURCES)
INIT_SOURCES+=init/main.ha

init/init: $(INIT_SOURCES)
	$(HAREBUILD) -o $@ init/

all: init/init
install-bin: init/init
