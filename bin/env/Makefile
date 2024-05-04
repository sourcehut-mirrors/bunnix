ENV_SOURCES=$(wildcard,env,*.ha)
ENV_SOURCES+=$(HARE_SOURCES)
ENV_SOURCES+=env/main.ha

env/env: $(ENV_SOURCES)
	$(HAREBUILD) -o $@ env/

all: env/env
install-bin: env/env
