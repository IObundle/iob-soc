ROOT_DIR:=../..
include ../software.mk

#additional linker flag
LFLAGS+= -Wl,-Map,boot.map

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
build: boot.elf

boot.elf: ../template.lds  $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(LFLAGS) $(DEFINE) $(INCLUDE) $(SRC) $(LLIBS)
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin

clean:
	@rm -rf boot.bin boot.elf boot.map *.hex *swreg*.h *swreg*.c

.PHONY: build clean
