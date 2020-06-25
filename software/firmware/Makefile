ROOT_DIR:=../..
include ../software.mk

#local flags
CFLAGS+=--std=gnu99 -Wl,-Bstatic,-T,../template.lds,-Map,firmware.map,--strip-debug

#local sources
SRC+= firmware.S firmware.c

firmware.elf: ../../system.mk ../template.lds $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	$(PYTHON_DIR)/makehex.py firmware.bin $(FIRM_ADDR_W) > firmware.hex

clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex *~

.PHONY: clean
