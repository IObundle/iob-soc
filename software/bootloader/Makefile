ROOT_DIR:=../..
include ../software.mk

#additional compiler flags
CFLAGS+=--specs=nano.specs -Wl,-Bstatic,-T,../template.lds,-Map,boot.map,--strip-debug

#cache
ifeq ($(USE_DDR),1)
ifeq ($(RUN_EXTMEM),1)
include $(CACHE_DIR)/software/software.mk
endif
endif

#UART
include $(UART_DIR)/software/embedded/embedded.mk

#SOURCES
SRC+=boot.S boot.c 

#RULES
boot.elf: ../template.lds  $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc -lnosys
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin

clean: gen-clean
	@rm -rf boot.bin boot.elf boot.map *.hex *sw_reg.h

.PHONY: clean
