ROOT_DIR=../..
include ../software.mk

#additional linker flag
LFLAGS+=-Wl,-Map,firmware.map

#cache
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/software/software.mk
endif

#uart
include $(UART_DIR)/software/embedded/embedded.mk

#core_ut
include $($(CORE_UT)_DIR)/software/embedded/embedded.mk

#include every other configured tester peripheral (in tester.mk of core under test)
$(foreach p, $(TESTER_PERIPHERALS), $(eval include $($p_DIR)/software/embedded/embedded.mk))

#HEADERS
HDR+=periphs.h

#SOURCES
SRC+= firmware.S firmware.c $(UART_DIR)/software/printf.c

#RULES
firmware.elf: ../template.lds $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(LFLAGS) $(DEFINE) $(INCLUDE) $(SRC) $(LLIBS)
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin

clean: gen-clean 
	@rm -rf firmware.bin firmware.elf firmware.map *.hex periphs.h *swreg.h

.PHONY: clean
