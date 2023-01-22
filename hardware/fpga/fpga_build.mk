IS_FPGA=1

#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_PARAM,<param_name>,<vh_path>)
GET_PARAM = $(shell grep $(1) $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_conf.vh
GET_CONF_PARAM = $(call GET_PARAM,$(1),../src/iob_soc_conf.vh)

boot.hex: ../../software/embedded/boot.bin
	../../scripts/makehex.py $< $(call GET_CONF_PARAM,BOOTROM_ADDR_W) > $@

firmware.hex: firmware.bin
	../../scripts/makehex.py $< $(call GET_CONF_PARAM,SRAM_ADDR_W) > $@
	../../scripts/hex_split.py firmware .

firmware.bin: ../../software/embedded/firmware.bin
	cp $< $@

../../software/embedded/%.bin:
	make -C ../../ fw-build

TEST_LIST+=test1
test1:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=1 RUN_EXTMEM=0 TEST_LOG=">> test.log"

TEST_LIST+=test1
test2:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"

TEST_LIST+=test1
test3:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=0 RUN_EXTMEM=1 TEST_LOG=">> test.log"
