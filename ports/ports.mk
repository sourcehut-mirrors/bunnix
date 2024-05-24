$(SYSROOT): $(SYSROOT)/usr/bin

clean: clean-ports

####                                 PORTS                                  ####

#### advent

ports/build-advent/src/advent: $(SYSROOT)/usr/lib/libc.a
	mkdir -p ports/build-advent/
	cd ports/build-advent/ && ../advent/configure \
		--prefix=/usr \
		--host=x86_64-bunnix
	cd ports/build-advent && make

$(SYSROOT)/usr/bin/advent: ports/build-advent/src/advent
	cd ports/build-advent/ && make install DESTDIR="$(ASYSROOT)"

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/advent

clean-advent:
	rm -rf ports/build-advent
.PHONY: clean-advent
clean-ports: clean-advent

#### doom

ports/doom/doomgeneric/doom: $(SYSROOT)/usr/lib/libc.a
	make -C ports/doom/doomgeneric -f Makefile.bunnix

$(SYSROOT)/usr/bin/doom: ports/doom/doomgeneric/doom
	cp ports/doom/doomgeneric/doom $(SYSROOT)/usr/bin/
	mkdir -p $(SYSROOT)/usr/share/games/doom/
	cp ports/doom/doom1.wad $(SYSROOT)/usr/share/games/doom/

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/doom

clean-doom:
	make -C ports/doom/doomgeneric -f Makefile.bunnix clean
.PHONY: clean-doom
clean-ports: clean-doom

#### gzip

ports/build-gzip/gzip: $(SYSROOT)/usr/lib/libc.a
	mkdir -p ports/build-gzip/
	cd ports/build-gzip/ && ../gzip/configure \
		--prefix=/usr \
		--host=x86_64-bunnix
	cd ports/build-gzip && make

$(SYSROOT)/usr/bin/gzip: ports/build-gzip/gzip
	cd ports/build-gzip/ && make install DESTDIR="$(ASYSROOT)"

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/gzip

clean-gzip:
	rm -rf ports/build-gzip
.PHONY: clean-gzip
clean-ports: clean-gzip

#### less

ports/build-less/less: $(SYSROOT)/usr/lib/libc.a $(SYSROOT)/usr/lib/libcurses.a
	mkdir -p ports/build-less/
	cd ports/build-less/ && ../less/configure \
		--prefix=/usr \
		--host=x86_64-bunnix
	cd ports/build-less && make
	# Fix unusual issues with timestamps
	touch ports/build-less/less

$(SYSROOT)/usr/bin/less: ports/build-less/less
	cp ports/build-less/less $(SYSROOT)/usr/bin/less

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/less

#### make

ports/build-make/make: $(SYSROOT)/usr/lib/libc.a
	mkdir -p ports/build-make/
	cd ports/build-make/ && ../make/configure \
		--prefix=/usr \
		--host=x86_64-bunnix
	cd ports/build-make && make

$(SYSROOT)/usr/bin/make: ports/build-make/make
	cd ports/build-make/ && make install DESTDIR="$(ASYSROOT)"
	rm -rf "$(SYSROOT)"/usr/share/info

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/make

clean-make:
	rm -rf ports/build-make
.PHONY: clean-make
clean-ports: clean-make

#### mandoc

ports/mdocml/mandoc: $(SYSROOT)/usr/lib/libc.a
	make -C ports/mdocml

$(SYSROOT)/usr/bin/man: ports/mdocml/mandoc
	make -C ports/mdocml install DESTDIR="$(ASYSROOT)"

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/man

clean-mandoc:
	make -C ports/mdocml clean
.PHONY: clean-mandoc
clean-ports: clean-mandoc

#### tcc

ports/build-tcc/tcc: $(SYSROOT)/usr/lib/libc.a
	mkdir -p ports/build-tcc/
	cd ports/build-tcc/ && ../tcc/configure \
		--prefix=/usr \
		--targetos=Bunnix \
		--enable-static \
		--cross-prefix=x86_64-bunnix-
	cd ports/build-tcc && make

$(SYSROOT)/usr/bin/cc: ports/build-tcc/tcc
	cd ports/build-tcc/ && make install DESTDIR="$(ASYSROOT)"
	mv $(ASYSROOT)/usr/bin/tcc $(ASYSROOT)/usr/bin/cc

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/cc

clean-tcc:
	rm -rf ports/build-tcc
.PHONY: clean-tcc
clean-ports: clean-tcc

#### vim

ports/vim57/vim: $(SYSROOT)/usr/lib/libc.a $(SYSROOT)/usr/lib/libcurses.a
	make -C ports/vim57

$(SYSROOT)/usr/bin/vim: ports/vim57/vim
	cp ports/vim57/vim $(SYSROOT)/usr/bin/vim

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/vim

clean-vim:
	make -C ports/vim57 clean
.PHONY: clean-vim
clean-ports: clean-vim
