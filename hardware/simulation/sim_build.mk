CONSOLE_CMD=../../scripts/console.py -L
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

#produce waveform dump
ifeq ($(VCD),1)
UFLAGS+=VCD
endif

VTOP:=system_tb

# Simulation programs
VHDR+=iob_soc_boot.hex iob_soc_firmware.hex

#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_PARAM,<param_name>,<vh_path>)
GET_PARAM = $(shell grep $(1) $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_conf.vh
GET_CONF_PARAM = $(call GET_PARAM,$(1),../src/iob_soc_conf.vh)

iob_soc_boot.hex: ../../software/embedded/iob_soc_boot.bin
	../../scripts/makehex.py $< $(call GET_CONF_PARAM,BOOTROM_ADDR_W) > $@

iob_soc_firmware.hex: iob_soc_firmware.bin
	../../scripts/makehex.py $< $(call GET_CONF_PARAM,SRAM_ADDR_W) > $@
	../../scripts/hex_split.py iob_soc_firmware .

iob_soc_firmware.bin: ../../software/embedded/iob_soc_firmware.bin
	cp $< $@

../../software/embedded/%.bin:
	make -C ../../ fw-build

# SOURCES
ifeq ($(SIMULATOR),verilator)

# get header files (needed for iob_soc_tb.cpp)
VHDR+=iob_uart_swreg.h
iob_uart_swreg.h: ../../software/esrc/iob_uart_swreg.h
	cp $< $@

# remove system_tb.v from source list
#VSRC:=$(filter-out system_tb.v, $(VSRC))
#
# verilator top module
VTOP:=system_top

endif

TEST_LIST+=test1
test1:
	make -C ../../ clean SIMULATOR=$(SIMULATOR)
	make run SIMULATOR=$(SIMULATOR) INIT_MEM=1 RUN_EXTMEM=0 TEST_LOG=">> test.log"
TEST_LIST+=test2
test2:
	make -C ../../ clean SIMULATOR=$(SIMULATOR)
	make run SIMULATOR=$(SIMULATOR) INIT_MEM=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
TEST_LIST+=test3
test3:
	make -C ../../ clean SIMULATOR=$(SIMULATOR)
	make run SIMULATOR=$(SIMULATOR) INIT_MEM=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
TEST_LIST+=test4
test4:
	make -C ../../ clean SIMULATOR=$(SIMULATOR)
	make run SIMULATOR=$(SIMULATOR) INIT_MEM=0 RUN_EXTMEM=1 TEST_LOG=">> test.log"
