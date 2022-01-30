SUT_DIR=../..
include ../software.mk

#additional compiler flags
CFLAGS+=--specs=nano.specs -Wl,-Bstatic,-T,../template.lds,--strip-debug
BOOT_CFLAGS=-Map,boot.map
FIRM_CFLAGS=-Map,firmware.map

#cache
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/software/software.mk
endif

#HEADERS
FIRM_HDR=tester_periphs.h

#SOURCES
BOOT_SRC=boot.S boot.c 
FIRM_SRC= firmware.S firmware.c $(UART_DIR)/software/printf.c

#peripherals (embedded)
$(foreach p, $(sort $(TESTER_PERIPHERALS)), $(eval include $($p_DIR)/software/embedded/embedded.mk))
#UART for bootloader
$(if $(filter UART, $(TESTER_PERIPHERALS)),, $(eval include $(UART_DIR)/software/embedded/embedded.mk))	
#interconnect for bootloader
$(if $(filter INTERCON, $(TESTER_PERIPHERALS)),, $(eval include $(INTERCON_DIR)/software/software.mk))	
#Include default REGFILEIF for communication between SUT and Tester for firmware
$(if $(filter REGFILEIF, $(TESTER_PERIPHERALS)),, $(eval include $(REGFILEIF_DIR)/software/embedded/embedded.mk))	

#RULES
boot.elf: ../template.lds  $(HDR) $(SRC) $(BOOT_SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS),$(BOOT_CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) $(BOOT_SRC) -lgcc -lc -lnosys
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin

firmware.elf: ../template.lds $(HDR) $(SRC) $(FIRM_SRC) $(FIRM_HDR)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS),$(FIRM_CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) $(FIRM_SRC) -lgcc -lc -lnosys
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin

clean: gen-clean 
	@rm -rf boot.bin boot.elf boot.map *.hex *sw_reg.h
	@rm -rf firmware.bin firmware.elf firmware.map *.hex periphs.h *sw_reg.h

.PHONY: clean
