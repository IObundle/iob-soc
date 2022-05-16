ROOT_DIR=../..
include ../software.mk

#additional linker flag
LFLAGS+=-Wl,-Map,firmware.map

#cache
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/software/software.mk
endif

#
# ADD SUBMODULES SOFTWARE
#

#uart
include $(UART_DIR)/software/embedded/embedded.mk

#regfileif
include $(REGFILEIF_DIR)/software/embedded/embedded.mk

# include CORE_UT and tester peripherals if we are testing a core
ifeq ($(TESTING_CORE),1)
#core_ut (only include if embedded.mk exists)
-include $($(CORE_UT)_DIR)/software/embedded/embedded.mk

#include every other configured tester peripheral (in tester.mk of core under test) (only include if embedded.mk exists)
$(foreach p, $(sort $(TESTER_PERIPHERALS)), $(eval -include $($p_DIR)/software/embedded/embedded.mk))
endif

#HEADERS
HDR+=periphs.h

#SOURCES
SRC+= firmware.S $(UART_DIR)/software/printf.c

#Use core under test firmware if we are testing a core
ifeq ($(TESTING_CORE),1)
SRC+=cut_firmware.c
else
SRC+=firmware.c
endif

#RULES

build: firmware.elf

firmware.elf: ../template.lds $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(LFLAGS) $(DEFINE) $(INCLUDE) $(SRC) $(LLIBS)
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin

clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex periphs.h *swreg.h \
		*swreg_emb.c

.PHONY: build clean
