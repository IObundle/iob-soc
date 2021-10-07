ROOT_DIR=../..
include ../software.mk

#additional compiler flags
CFLAGS+=--specs=nano.specs -Wl,-Bstatic,-T,../template.lds,-Map,firmware.map,--strip-debug


#SUBMODULES

#cache
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/software/software.mk
endif

#peripherals (embedded)
$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/software/embedded/embedded.mk))

#HEADERS
HDR+=periphs.h

#SOURCES
SRC+= firmware.S firmware.c $(UART_DIR)/software/printf.c

#RULES
firmware.elf: ../template.lds $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc -lnosys
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin

clean: gen-clean 
	@rm -rf firmware.bin firmware.elf firmware.map *.hex periphs.h

.PHONY: clean
