include $(ROOT)config.mk
include $(ROOT)mk/$(ARCH).conf.mk

# Kernel build configuration
KHAREPATH=$(ROOT)sys/
KHAREFLAGS=-a$(HAREARCH) -T^+$(HAREARCH)+bunnix -RF
KHAREBUILD=HAREPATH=$(KHAREPATH) $(HARE) build $(KHAREFLAGS)

# Bootloader build configuration
BHAREPATH=$(ROOT)sys/
BHAREFLAGS=-a$(HAREARCH) -T^+$(HAREARCH)+mb -RF
BHAREBUILD=HAREPATH=$(BHAREPATH) $(HARE) build $(BHAREFLAGS)
