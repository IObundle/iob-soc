include ../software.mk

#additional flags
CFLAGS+=-Wl,-Bstatic,-T,../template.lds,-Map,boot.map,--strip-debug

#additional paths
CACHE_DIR:=$(SUBMODULES_DIR)/cache/c-driver

#additional defines
DEFINE+=-DPROG_SIZE=`wc -c   ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1`
DEFINE+=-DBOOTROM_ADDR_W=$(BOOTROM_ADDR_W) -DBOOT_CTR=$(BOOT_CTR)
DEFINE+=-DFIRM_ADDR_W=$(SRAM_ADDR_W)

#additional includes
INCLUDE+=-I$(CACHE_DIR)

#additional includes
SRC+=boot.S boot.c $(CACHE_DIR)/iob-cache.c 

boot.elf:  ../template.lds ../system.h $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	$(PYTHON_DIR)/makehex.py boot.bin $(BOOTROM_ADDR_W) > boot.hex

clean:
	@rm -rf boot.bin boot.elf boot.map *.hex

.PHONY: clean
