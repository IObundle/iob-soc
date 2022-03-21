
VSRC+=tester.v
IMAGES+=tester_boot.hex tester_firmware.hex init_ddr_contents.hex

#Add TESTER_N_SLAVES to define list
DEFINE+=$(defmacro)TESTER_N_SLAVES=$(shell $(TESTER_DIR)/tester_utils.py get_n_slaves $(ROOT_DIR))

#Add Tester peripheral sequetial numbers
DEFINE+=$(shell $(TESTER_DIR)/tester_utils.py get_defines $(ROOT_DIR) $(defmacro))

# Create tester from system_core.v and include SUT
tester.v: $(SRC_DIR)/system_core.v
	$(TESTER_DIR)/tester_utils.py create_tester $(ROOT_DIR)
	
# tester init files
tester_boot.hex: $(SW_DIR)/tester/boot.bin
	$(PYTHON_DIR)/makehex.py $(SW_DIR)/tester/boot.bin $(BOOTROM_ADDR_W) > $@

tester_firmware.hex: $(SW_DIR)/tester/firmware.bin
	$(PYTHON_DIR)/makehex.py $(SW_DIR)/tester/firmware.bin $(FIRM_ADDR_W) > $@
	$(PYTHON_DIR)/hex_split.py tester_firmware
	cp $(SW_DIR)/tester/firmware.bin tester_firmware.bin

# init file for external mem with firmware of both systems
init_ddr_contents.hex: firmware.hex tester_firmware.hex
	$(SW_DIR)/python/joinHexFiles.py firmware.hex tester_firmware.hex $(DDR_ADDR_W) > $@

# make embedded Tester software
tester-sw:
	make -C $(SW_DIR)/tester firmware.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(SW_DIR)/tester boot.elf FREQ=$(FREQ) BAUD=$(BAUD)

.PHONY: tester-sw

