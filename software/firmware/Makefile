include ../software.mk

#additional flags
CFLAGS+=--std=gnu99 -Wl,-Bstatic,-T,../template.lds,-Map,firmware.map,--strip-debug

#additional defines 
DEFINE+=-DUSE_SRAM=$(USE_SRAM) -DUSE_DDR=$(USE_DDR)
ifeq ($(USE_DDR),1)
ifeq ($(RUN_DDR),1)
DEFINE+=-DFIRM_ADDR_W=$(DDR_ADDR_W)
FIRM_ADDR_W=$(DDR_ADDR_W)
else
DEFINE+=-DFIRM_ADDR_W=$(SRAM_ADDR_W)
FIRM_ADDR_W=$(SRAM_ADDR_W)
endif
else
DEFINE+=-DFIRM_ADDR_W=$(SRAM_ADDR_W)
FIRM_ADDR_W=$(SRAM_ADDR_W)
endif
DEFINE+=-DUSE_BOOT=$(USE_BOOT)

#additional sources
SRC+= firmware.S firmware.c

firmware.elf: ../template.lds ../system.h  $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	$(PYTHON_DIR)/makehex.py firmware.bin $(FIRM_ADDR_W) > firmware.hex

clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex

.PHONY: clean
