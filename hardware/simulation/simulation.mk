#default baud and freq for simulation
BAUD=$(SIM_BAUD)
FREQ=$(SIM_FREQ)

#define for testbench
DEFINE+=BAUD=$(BAUD)
DEFINE+=FREQ=$(FREQ)

#ddr controller address width
DDR_ADDR_W=$(DCACHE_ADDR_W)
DEFINE+=DDR_ADDR_W=$(DDR_ADDR_W)

#use hard multiplier and divider instructions
DEFINE+=USE_MUL_DIV=$(USE_MUL_DIV)

#use compressed instructions
DEFINE+=USE_COMPRESSED=$(USE_COMPRESSED)

CONSOLE_CMD=../../sw/python/console -L

#produce waveform dump
VCD ?=0

ifeq ($(VCD),1)
DEFINE+=VCD
endif

ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

ifneq ($(wildcard firmware.hex),)
FW_SIZE=$(shell wc -l firmware.hex | awk '{print $$1}')
endif

DEFINE+=FW_SIZE=$(FW_SIZE)

# HEADERS
VHDR+=defines.vh

defines.vh:
	../../sw/python/hw_defines.py $@ $(DEFINE)

VHDR+=boot.hex firmware.hex

boot.hex: ../../sw/emb/boot.bin
	../../sw/python/makehex.py $< $(BOOTROM_ADDR_W) > $@

firmware.hex: ../../sw/emb/firmware.bin
	../../sw/python/makehex.py $< $(FIRM_ADDR_W) > $@
	../../sw/python/hex_split.py firmware .

../../sw/emb%.bin:
	make -C ../../ fw-build

# SOURCES
# remove cpu_tasks.v from source list
VSRC:=$(filter-out %cpu_tasks.v, $(VSRC))
# remove non-system testbenches
NON_SOC_TB=$(filter-out %system_tb.v, $(filter %_tb.v, $(VSRC)))
$(warning $(NON_SOC_TB))
VSRC:=$(filter-out $(NON_SOC_TB), $(VSRC))

TEST_LIST+=test1
test1:
	make -C $(ROOT_DIR) sim-clean SIMULATOR=$(SIMULATOR)
	make -C $(ROOT_DIR) sim-run INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0
TEST_LIST+=test2
test2:
	make -C $(ROOT_DIR) sim-clean SIMULATOR=$(SIMULATOR)
	make -C $(ROOT_DIR) sim-run INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0
TEST_LIST+=test3
test3:
	make -C $(ROOT_DIR) sim-clean SIMULATOR=$(SIMULATOR)
	make -C $(ROOT_DIR) sim-run INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=0
TEST_LIST+=test4
test4:
	make -C $(ROOT_DIR) sim-clean SIMULATOR=$(SIMULATOR)
	make -C $(ROOT_DIR) sim-run INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=1
TEST_LIST+=test5
test5:
	make -C $(ROOT_DIR) sim-clean SIMULATOR=$(SIMULATOR)
	make -C $(ROOT_DIR) sim-run INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1
