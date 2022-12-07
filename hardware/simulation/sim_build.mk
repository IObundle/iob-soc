CONSOLE_CMD=../../scripts/console -L
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

#produce waveform dump
ifeq ($(VCD),1)
UFLAGS+=VCD
endif

UFLAGS+=FW_SIZE=$(shell wc -l firmware.hex | awk '{print $$1}')

# Simulation programs
VHDR+=boot.hex firmware.hex

#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_PARAM,<param_name>,<vh_path>)
GET_PARAM = $(shell grep $(1) $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_conf.vh
GET_CONF_PARAM = $(call GET_PARAM,$(1),../src/iob_soc_conf.vh)

boot.hex: ../../software/embedded/boot.bin
	../../scripts/makehex.py $< $(call GET_CONF_PARAM,BOOTROM_ADDR_W) > $@

firmware.hex: firmware.bin
	../../scripts/makehex.py $< $(call GET_CONF_PARAM,FIRM_ADDR_W) > $@
	../../scripts/hex_split.py firmware .

firmware.bin: ../../software/embedded/firmware.bin
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
endif

# verilator top module
#VTOP:=system_top

TEST_LIST+=test1
test1:
	make clean SIMULATOR=$(SIMULATOR)
	make run SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
#TEST_LIST+=test2 TEST_LOG=">> test.log"
#test2:
#	make clean SIMULATOR=$(SIMULATOR)
#	make run SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
# TEST_LIST+=test3 TEST_LOG=">> test.log"
# test3:
# 	make -C $(SOC_DIR) sim-clean SIMULATOR=$(SIMULATOR)
# 	make -C $(SOC_DIR) sim-run SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=0 TEST_LOG=">> test.log"
# TEST_LIST+=test4 TEST_LOG=">> test.log"
# test4:
# 	make -C $(SOC_DIR) sim-clean SIMULATOR=$(SIMULATOR)
# 	make -C $(SOC_DIR) sim-run SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
# TEST_LIST+=test5 TEST_LOG=">> test.log"
# test5:
# 	make -C $(SOC_DIR) sim-clean SIMULATOR=$(SIMULATOR)
# 	make -C $(SOC_DIR) sim-run SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"

#NOCLEAN+=-o -name "system_tb.v"
#NOCLEAN+=-o -name "system_top.v"
#NOCLEAN+=-o -name "iob_soc_tb.cpp"
