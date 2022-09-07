#default baud and freq for simulation
BAUD=$(SIM_BAUD)
FREQ=$(SIM_FREQ)

#define for testbench
CONF_DEFINE+=BAUD=$(BAUD)
CONF_DEFINE+=FREQ=$(FREQ)

#ddr controller address and data width
CONF_DEFINE+=DDR_ADDR_W=$(DCACHE_ADDR_W)
CONF_DEFINE+=DDR_DATA_W=$(DATA_W)

# DDR configuration
ifeq ($(USE_DDR),1)
CONF_DEFINE+=USE_DDR
endif
ifeq ($(RUN_EXTMEM),1)
CONF_DEFINE+=RUN_EXTMEM
endif

# Initialize Memory configuration
ifeq ($(INIT_MEM),1)
CONF_DEFINE+=INIT_MEM
endif

CONSOLE_CMD=../../sw/python/console -L
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

#produce waveform dump
ifeq ($(VCD),1)
TB_DEFINE+=VCD
endif

FW_SIZE=$(shell wc -l firmware.hex | awk '{print $$1}')

TB_DEFINE+=FW_SIZE=$(FW_SIZE)

# Simulation programs
VHDR+=boot.hex firmware.hex

# HEADERS
VHDR+=iob_soc_conf.vh iob_soc_tb_conf.vh

iob_soc_conf.vh:
	../../sw/python/hw_defines.py $@ $(CONF_DEFINE)

iob_soc_tb_conf.vh:
	../../sw/python/hw_defines.py $@ $(TB_DEFINE)

boot.hex: ../../sw/emb/boot.bin
	../../sw/python/makehex.py $< $(BOOTROM_ADDR_W) > $@

firmware.hex: firmware.bin
	../../sw/python/makehex.py $< $(FIRM_ADDR_W) > $@
	../../sw/python/hex_split.py firmware .

firmware.bin: ../../sw/emb/firmware.bin
	cp $< $@

../../sw/emb%.bin:
	make -C ../../ fw-build

# SOURCES
ifeq ($(SIMULATOR),verilator)

# get header files (needed for iob_soc_tb.cpp
VHDR+=iob_uart_swreg.h
iob_uart_swreg.h: ../../sw/src/iob_uart_swreg.h
	cp $< $@

VHDR+=iob_soc_conf.h iob_soc_tb_conf.h
iob_soc_conf.h:
	../../sw/python/sw_defines.py $@ $(CONF_DEFINE)

iob_soc_tb_conf.h:
	../../sw/python/sw_defines.py $@ $(TB_DEFINE)

# remove system_tb.v from source list
VSRC:=$(filter-out system_tb.v, $(VSRC))
endif

# verilator top module
VTOP:=system_top

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

NOCLEAN+=-o -name "system_tb.v"
NOCLEAN+=-o -name "system_top.v"
NOCLEAN+=-o -name "iob_soc_tb.cpp"
