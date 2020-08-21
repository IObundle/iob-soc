ROOT_DIR:=../..
include $(ROOT_DIR)/software/software.mk
include $(UART_DIR)/software/embedded/embedded.mk

ifeq ($(USE_DDR),1)
ifeq ($(RUN_DDR),1)
include $(CACHE_DIR)/software/software.mk
endif
endif


#specific compiler flags
CFLAGS+=--specs=nano.specs -Wl,-Bstatic,-T,../template.lds,-Map,boot.map,--strip-debug

#specific sources
SRC+=boot.S boot.c 

run: boot.elf

boot.elf: ../template.lds  $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc -lnosys
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin

clean:
	@rm -rf boot.bin boot.elf boot.map *.hex ../periphs.h *~

.PHONY: clean
