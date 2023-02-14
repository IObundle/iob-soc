#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_MACRO,<param_name>,<vh_path>)
GET_MACRO = $(shell grep $(1) $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_conf.vh
GET_CONF_MACRO = $(call GET_MACRO,IOB_SOC_$(1),../src/iob_soc_conf.vh)

iob_soc_preboot.hex: ../../software/embedded/iob_soc_preboot.bin
	../../scripts/makehex.py $< $(call GET_CONF_MACRO,ROM_ADDR_W) > $@

iob_soc_boot.hex: ../../software/embedded/iob_soc_boot.bin
	../../scripts/makehex.py $< $(call GET_CONF_MACRO,ROM_ADDR_W) > $@

iob_soc_rom.hex: iob_soc_preboot.hex iob_soc_boot.hex
	cat $^ > $@

iob_soc_firmware.hex: iob_soc_firmware.bin
	../../scripts/makehex.py $< $(call GET_CONF_MACRO,RAM_ADDR_W) > $@
	../../scripts/hex_split.py iob_soc_firmware .

iob_soc_firmware.bin: ../../software/embedded/iob_soc_firmware.bin
	cp $< $@

../../software/embedded/%.bin:
	make -C ../../ fw-build
