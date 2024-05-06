include $(ROOT)config.mk
include $(ROOT)mk/$(ARCH).conf.mk

SYSROOT=$(ROOT)target/root/

# Kernel build configuration
KHAREPATH=$(ROOT)sys/
KHAREFLAGS=-a$(HAREARCH) -T^+$(HAREARCH)+bunnix -RF
KHAREBUILD=HAREPATH=$(KHAREPATH) $(HARE) build $(KHAREFLAGS)

# Bootloader build configuration
BHAREPATH=$(ROOT)sys/
BHAREFLAGS=-a$(HAREARCH) -T^+$(HAREARCH)+mb -RF
BHAREBUILD=HAREPATH=$(BHAREPATH) $(HARE) build $(BHAREFLAGS)

# Userspace build configuration
HAREPATH=$(ROOT)lib/hare/
HAREFLAGS=-a$(HAREARCH) -T^+$(HAREARCH)+bunnix -R
HAREBUILD=HAREPATH=$(HAREPATH) $(HARE) build $(HAREFLAGS)

# C build configuration
USER_CFLAGS=--sysroot=$(SYSROOT) -std=c11 -Wall -Wextra -Wpedantic -isystem=/usr/include
USER_CBUILD=$(CC) $(USER_CFLAGS)

# Various macros
MKDIR=mkdir -p $$(dirname $@)
# https://stackoverflow.com/questions/2483182/recursive-wildcards-in-gnu-make
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
HARE_SOURCES=$(call rwildcard,$(ROOT)lib/hare/,*.ha *.s *.sc)
