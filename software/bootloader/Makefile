ROOT_DIR:=../..
include $(ROOT_DIR)/software/software.mk
include $(CACHE_DIR)/software/software.mk

#specific compiler flags
CFLAGS+=-Wl,-Bstatic,-T,../template.lds,-Map,boot.map,--strip-debug

#specific sources
SRC+=boot.S boot.c 

run: boot.elf

boot.elf: ../template.lds  $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin

clean:
	@rm -rf boot.bin boot.elf boot.map *.hex ../periphs.h *~

.PHONY: clean
