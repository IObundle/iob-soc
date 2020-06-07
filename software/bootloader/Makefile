include ../software.mk

#local flags
CFLAGS+=-Wl,-Bstatic,-T,../template.lds,-Map,boot.map,--strip-debug

#local paths
CACHE_DIR:=$(SUBMODULES_DIR)/cache/c-driver

#local defines
DEFINE+=-DPROG_SIZE=`wc -c   ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1`
DEFINE+=-DUSE_BOOT=$(USE_BOOT) -DBOOTROM_ADDR_W=$(BOOTROM_ADDR_W) 
DEFINE+=-DRUN_DDR=$(RUN_DDR) -DDDR_ADDR_W=$(DDR_ADDR_W)

#else
#define BOOTCTR_BASE (1 << SRAM_ADDR_W)


#local includes
INCLUDE+=-I$(CACHE_DIR)

#local sources
HDR:=../system.h ./boot.h
SRC+=boot.S boot.c $(CACHE_DIR)/iob-cache.c

boot.elf: ../../system.mk ../template.lds  $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	$(PYTHON_DIR)/makehex.py boot.bin $(BOOTROM_ADDR_W) > boot.hex

clean:
	@rm -rf boot.bin boot.elf boot.map *.hex *~

.PHONY: clean
