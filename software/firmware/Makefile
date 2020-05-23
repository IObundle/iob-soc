include ../embedded.mk

#additional flags
CFLAGS+=--std=gnu99 -Wl,-Bstatic,-T,../template.lds,-Map,firmware.map,--strip-debug

#additional defines 
DEFINE+=-DUSE_SRAM=$(USE_SRAM) -DUSE_DDR=$(USE_DDR)
ifeq (RUN_DDR,1)
DEFINE+=-DFIRM_ADDR_W=$(DDR_ADDR_W)
else
DEFINE+=-DFIRM_ADDR_W=$(SRAM_ADDR_W)
endif

#additional sources
SRC+= firmware.c

firmware.elf: ../template.lds ../system.h  $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	$(PYTHON_DIR)/makehex.py firmware.bin $(SRAM_ADDR_W) > firmware.hex

clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex

.PHONY: clean
