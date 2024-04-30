ECHO_SOURCES=$(wildcard,echo,*.ha)
ECHO_SOURCES+=$(HARE_SOURCES)
ECHO_SOURCES+=echo/main.ha

echo/echo: $(ECHO_SOURCES)
	$(HAREBUILD) -o $@ echo/

all: echo/echo
install-bin: echo/echo
