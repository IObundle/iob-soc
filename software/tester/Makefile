ROOT_DIR=../..
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
BOOT_SRC=$(BOOT_DIR)/boot.S boot.c 
FIRM_SRC= firmware.S firmware.c $(UART_DIR)/software/printf.c

#peripherals (embedded)
$(foreach p, $(sort $(TESTER_PERIPHERALS)), $(eval include $($p_DIR)/software/embedded/embedded.mk))
#UART for bootloader
$(if $(filter UART, $(TESTER_PERIPHERALS)),, $(eval include $(UART_DIR)/software/embedded/embedded.mk))	
#interconnect for bootloader
include $(INTERCON_DIR)/software/software.mk

#Replace SUT N_SLAVES by Tester N_SLAVES
TESTER_N_SLAVES=$(shell python3 $(TESTER_DIR)/tester_utils.py get_n_slaves $(ROOT_DIR))
DEFINE:=$(patsubst $(defmacro)N_SLAVES=%,$(defmacro)N_SLAVES=$(TESTER_N_SLAVES),$(DEFINE))

#Replace SUT peripheral sequential numbers by Tester peripheral sequetial numbers
DEFINE:=$(shell python3 $(TESTER_DIR)/tester_utils.py replace_peripheral_defines $(ROOT_DIR) "$(DEFINE)" $(defmacro))

#RULES
#make bootloader based on bootloader from SUT
boot.c: $(BOOT_DIR)/boot.c 
	python3 createTesterBoot.py $(ROOT_DIR)

boot.elf: ../template.lds  $(HDR) $(SRC) $(BOOT_SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS),$(BOOT_CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) $(BOOT_SRC) -lgcc -lc -lnosys
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin

firmware.elf: ../template.lds $(HDR) $(SRC) $(FIRM_SRC) $(FIRM_HDR)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS),$(FIRM_CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) $(FIRM_SRC) -lgcc -lc -lnosys
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin

clean: gen-clean 
	@rm -rf boot.c boot.bin boot.elf boot.map *.hex *sw_reg.h
	@rm -rf firmware.bin firmware.elf firmware.map *.hex periphs.h *sw_reg.h

.PHONY: clean
