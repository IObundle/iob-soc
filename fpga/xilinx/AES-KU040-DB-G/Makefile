# File paths
ROOT_DIR := ../../..
RTL_DIR := $(ROOT_DIR)/rtl
FIRM_DIR := $(ROOT_DIR)/software/firmware
BOOT_DIR := $(ROOT_DIR)/software/bootloader
LD_SW_DIR := $(ROOT_DIR)/software/ld-sw
PYTHON_DIR := $(ROOT_DIR)/software/python

SUBMODULES_DIR := $(ROOT_DIR)/submodules
RISCV_DIR := $(SUBMODULES_DIR)/picorv32
UART_DIR := $(SUBMODULES_DIR)/uart
MEM_DIR := $(SUBMODULES_DIR)/mem
CACHE_DIR := $(SUBMODULES_DIR)/cache
AXI_RAM_DIR := $(SUBMODULES_DIR)/axi-mem
INTERCON_DIR := $(SUBMODULES_DIR)/interconnect

REMOTE := ${USER}@146.193.44.179:sandbox/iob-soc/fpga/xilinx/AES-KU040-DB-G

BAUD := 115200
FREQ := 100000000

#hw defines
include $(ROOT_DIR)/system.mk

ifeq ($(USE_SRAM),1)
RAM_VSRC:=$(RTL_DIR)/src/int_mem.v $(RTL_DIR)/src/ram.v $(MEM_DIR)/tdp_ram/iob_tdp_ram.v
endif

ifeq ($(USE_DDR),1)
DDR_VSRC:=$(RTL_DIR)/src/ext_mem.v $(CACHE_DIR)/rtl/src/iob-cache.v \
$(AXI_RAM_DIR)/rtl/axi_ram.v $(MEM_DIR)/reg_file/iob_reg_file.v $(MEM_DIR)/fifo/afifo/afifo.v \
$(MEM_DIR)/sp_ram/iob_sp_mem.v
endif

ifeq ($(USE_BOOT),1)
ROM_VSRC$:=$(MEM_DIR)/sp_rom/sp_rom.v $(RTL_DIR)/src/boot_ctr.v
endif

#hardware sources
VSRC = \
verilog/top_system.v \
$(RTL_DIR)/include/*.vh \
$(RTL_DIR)/src/system.v \
$(RISCV_DIR)/picorv32.v \
$(RISCV_DIR)/iob_picorv32.v \
$(UART_DIR)/rtl/src/iob-uart.v \
$(INTERCON_DIR)/rtl/src/merge.v \
$(INTERCON_DIR)/rtl/src/split.v \
$(ROM_VSRC) $(RAM_VSRC) $(DDR_VSRC)

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

all: firmware.dat synth_system.bit
	scp synth_system.bit $(REMOTE)
	scp firmware*.dat $(REMOTE)

synth_system.bit: *.xdc $(VSRC) boot.dat
	rm -f $@.log
	echo $(USE_DDR)
	./run_vivado.sh $(USE_DDR)
	-grep -B4 -A10 'CLB LUTs' vivado.log
	-grep -B1 -A9 ^Slack vivado.log && echo

firmware.dat: $(FIRM_DIR)/firmware.hex
	cp $< .
	$(PYTHON_DIR)/hex_split.py firmware

$(FIRM_DIR)/firmware.hex: FORCE
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

boot.dat: $(BOOT_DIR)/boot.hex
	cp $< ./boot.dat

$(BOOT_DIR)/boot.hex: FORCE
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

ld-hw:
	./ld-hw.sh

ld-sw:
	cp firmware.bin $(LD_SW_DIR)
	make -C $(LD_SW_DIR)

clean:
	@rm -rf .Xil/ *.hex *.dat *.bin *.map
	@rm -rf *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*# ./rtl/
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb 
	@rm -rf table.txt tab_*/ *webtalk* *.jou *.log
	@rm -rf xelab.* xsim[._]* xvlog.* uart_loader
	@rm -rf *.ltx fsm_encoding.os
	make -C $(FIRM_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(LD_SW_DIR) clean --no-print-directory

.PHONY: all ld-hw ld-sw clean FORCE
