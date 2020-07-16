ROOT_DIR:=../..
include ../software.mk

#local flags
CFLAGS+=--std=gnu99 -Wl,-Bstatic,-T,../template.lds,-Map,firmware.map,--strip-debug

#local sources
HDR+=$(SW_DIR)/periphs.h
SRC+= firmware.S firmware.c

run: firmware.elf

firmware.elf: ../template.lds $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	$(PYTHON_DIR)/makehex.py firmware.bin $(FIRM_ADDR_W) > firmware.hex

clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex ../periphs.h *~

.PHONY: run clean
