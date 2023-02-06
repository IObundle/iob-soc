#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_PARAM,<param_name>,<vh_path>)
GET_PARAM = $(shell grep $(1) $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_tester_conf.vh
GET_TESTER_CONF_PARAM = $(call GET_PARAM,IOB_SOC_TESTER_$(1),../src/iob_soc_tester_conf.vh)

iob_soc_tester_boot.hex: ../../software/embedded/iob_soc_tester_boot.bin
	../../scripts/makehex.py $< $(call GET_TESTER_CONF_PARAM,BOOTROM_ADDR_W) > $@

iob_soc_tester_firmware.hex: iob_soc_tester_firmware.bin
	../../scripts/makehex.py $< $(call GET_TESTER_CONF_PARAM,SRAM_ADDR_W) > $@
	../../scripts/hex_split.py iob_soc_tester_firmware .

iob_soc_tester_firmware.bin: ../../software/embedded/iob_soc_tester_firmware.bin
	cp $< $@

../../software/embedded/%.bin:
	make -C ../../ fw-build
