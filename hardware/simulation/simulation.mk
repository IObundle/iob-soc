#default baud and freq for simulation
BAUD=$(SIM_BAUD)
FREQ=$(SIM_FREQ)

#define for testbench
CONF_DEFINE+=BAUD=$(BAUD)
CONF_DEFINE+=FREQ=$(FREQ)

#ddr controller address and data width
CONF_DEFINE+=DDR_ADDR_W=$(DCACHE_ADDR_W)
CONF_DEFINE+=DDR_DATA_W=$(DATA_W)

CONSOLE_CMD=../../sw/python/console -L

#produce waveform dump
VCD ?=0

ifeq ($(VCD),1)
TB_DEFINE+=VCD
endif

ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

ifneq ($(wildcard firmware.hex),)
FW_SIZE=$(shell wc -l firmware.hex | awk '{print $$1}')
endif

TB_DEFINE+=FW_SIZE=$(FW_SIZE)

# HEADERS
VHDR+=iob_soc_conf.vh iob_soc_tb_conf.vh

iob_soc_conf.vh:
	../../sw/python/hw_defines.py $@ $(CONF_DEFINE)

iob_soc_tb_conf.vh:
	../../sw/python/hw_defines.py $@ $(TB_DEFINE)

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
