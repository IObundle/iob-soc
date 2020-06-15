include ../software.mk

#local define
ifeq ($(USE_BOOT),1)
DEFINE+=-DUSE_BOOT
endif

#local flags
CFLAGS+=--std=gnu99 -Wl,-Bstatic,-T,../template.lds,-Map,firmware.map,--strip-debug

#local sources
HDR:=../system.h ./firmware.h
SRC+= firmware.S firmware.c

#
#local defines
#

#use boot
ifeq ($(USE_BOOT),1)
DEFINE+=-DUSE_BOOT
endif

#run ddr 
DEFINE+=-DRUN_DDR=$(RUN_DDR)

#firmware size according to SRAM or DDR
ifeq ($(USE_DDR),1)
	ifeq ($(RUN_DDR),0)
		FIRM_ADDR_W=$(SRAM_ADDR_W)
		DEFINE+=-DFIRM_ADDR_W=$(SRAM_ADDR_W)
	else
		DEFINE+=-DFIRM_ADDR_W=$(FIRM_ADDR_W)
	endif
else
	FIRM_ADDR_W=$(SRAM_ADDR_W)
	DEFINE+=-DFIRM_ADDR_W=$(SRAM_ADDR_W)
endif

firmware.elf: ../../system.mk ../template.lds $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	$(PYTHON_DIR)/makehex.py firmware.bin $(FIRM_ADDR_W) > firmware.hex

clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex *~

.PHONY: clean
