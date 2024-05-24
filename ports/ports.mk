$(SYSROOT): $(SYSROOT)/usr/bin $(SYSROOT)/dist

clean: clean-ports

####                                BUNDLES                                 ####

DISTROOT=$(AROOT)/target/dist

## devel.tar.gz

DIST_DEVEL=$(SYSROOT)/dist/devel.tar.gz

$(DIST_DEVEL):
	mkdir -p $(SYSROOT)/dist
	cd $(DISTROOT)/devel && tar -czf \
		$(ASYSROOT)/dist/devel.tar.gz *

$(SYSROOT)/dist: $(DIST_DEVEL)

####                                 PORTS                                  ####

$(SYSROOT)/usr/bin/distinstall: ports/distinstall
	mkdir -p $(SYSROOT)/usr/bin
	cp $^ $@

$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/distinstall

#### advent

ports/build-advent/src/advent: $(SYSROOT)/usr/lib/libc.a
	mkdir -p ports/build-advent/
	cd ports/build-advent/ && ../advent/configure \
		--prefix=/usr \
		--host=x86_64-bunnix
	cd ports/build-advent && make

$(SYSROOT)/usr/bin/advent: ports/build-advent/src/advent
	cd ports/build-advent/ && make install DESTDIR="$(ASYSROOT)"

# advent is installed by default
$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/advent

clean-advent:
	rm -rf ports/build-advent
.PHONY: clean-advent
clean-ports: clean-advent

#### gzip

ports/build-gzip/gzip: $(SYSROOT)/usr/lib/libc.a
	mkdir -p ports/build-gzip/
	cd ports/build-gzip/ && ../gzip/configure \
		--prefix=/usr \
		--host=x86_64-bunnix
	cd ports/build-gzip && make

$(SYSROOT)/usr/bin/gzip: ports/build-gzip/gzip
	cd ports/build-gzip/ && make install DESTDIR="$(ASYSROOT)"

# gzip is installed by default, it is required to unpack ports
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

# less is installed by default
$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/less

#### make

ports/build-make/make: $(SYSROOT)/usr/lib/libc.a
	mkdir -p ports/build-make/
	cd ports/build-make/ && ../make/configure \
		--prefix=/usr \
		--host=x86_64-bunnix
	cd ports/build-make && make

$(DISTROOT)/devel/usr/bin/make: ports/build-make/make
	cd ports/build-make/ && make install DESTDIR="$(DISTROOT)/devel"

$(SYSROOT)/dist/devel.tar.gz: $(DISTROOT)/devel/usr/bin/make

$(DIST_DEVEL): $(DISTROOT)/devel/usr/bin/make

clean-make:
	rm -rf ports/build-make
.PHONY: clean-make
clean-ports: clean-make

#### mandoc

ports/mdocml/mandoc: $(SYSROOT)/usr/lib/libc.a
	make -C ports/mdocml

$(SYSROOT)/usr/bin/man: ports/mdocml/mandoc
	make -C ports/mdocml install DESTDIR="$(ASYSROOT)"

# mandoc is installed by default
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

$(DISTROOT)/devel/usr/bin/cc: ports/build-tcc/tcc
	cd ports/build-tcc/ && make install DESTDIR="$(DISTROOT)/devel"
	mv $(DISTROOT)/devel/usr/bin/tcc $(DISTROOT)/devel/usr/bin/cc

$(SYSROOT)/dist/devel.tar.gz: $(DISTROOT)/devel/usr/bin/cc

$(DIST_DEVEL): $(DISTROOT)/devel/usr/bin/cc

clean-tcc:
	rm -rf ports/build-tcc
.PHONY: clean-tcc
clean-ports: clean-tcc

#### vim

ports/vim57/vim: $(SYSROOT)/usr/lib/libc.a $(SYSROOT)/usr/lib/libcurses.a
	make -C ports/vim57

$(SYSROOT)/usr/bin/vim: ports/vim57/vim
	cp ports/vim57/vim $(SYSROOT)/usr/bin/vim

# vim is installed by default
$(SYSROOT)/usr/bin: $(SYSROOT)/usr/bin/vim

clean-vim:
	make -C ports/vim57 clean
.PHONY: clean-vim
clean-ports: clean-vim
