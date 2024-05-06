include $(ROOT)config.mk
include $(ROOT)mk/$(ARCH).conf.mk

# https://stackoverflow.com/questions/2483182/recursive-wildcards-in-gnu-make
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

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

# TODO: Generate me?
HARE_SOURCES=$(call rwildcard,$(ROOT)lib/hare/,*.ha *.s *.sc)

SYSROOT=$(ROOT)target/root/

MKDIR=mkdir -p $$(dirname $@)
