#hardware configuration
USE_RAM = 1
USE_DDR = 0
BAUD = 115200

MY_PC = $(shell hostname)
ifeq ($(MY_PC),pudim-flan)
VIVADO_BASE = /home/iobundle/Xilinx/Vivado/2017.4
else ifeq ($(MY_PC),baba-de-camelo)
VIVADO_BASE = /home/Xilinx/Vivado/2018.3
endif

VIVADO = $(VIVADO_BASE)/bin/vivado
XELAB = $(VIVADO_BASE)/bin/xelab
GLBL = $(VIVADO_BASE)/data/verilog/src/glbl.v

SYNTH_TARGET := system
PROG_TARGET := $(SYNTH_TARGET)

export VIVADO

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

#software configuration
TEST_DIR := ../../../software/hello_world
BOOT_DIR := ../../../software/bootloader
BAUD = 115200

#software defines

DEFINE = -DUART_BAUD_RATE=$(BAUD)

ifeq ($(USE_RAM),1)
HWDEFINE := USE_RAM_1
DEFINE += -DUSE_RAM
else
HWDEFINE := USE_RAM_0
endif	

ifeq ($(USE_DDR),1)
HWDEFINE += USE_DDR_1
DEFINE += -DUSE_DDR
else
HWDEFINE := USE_DDR_0
endif

all: synth_$(SYNTH_TARGET)

synth_%: boot.hex #firmware.hex boot.hex
	rm -f $@.log
	$(VIVADO) -nojournal -log $@.log -mode batch -source $@.tcl -tclargs $(HWDEFINE)
	rm -rf .Xil fsm_encoding.os synth_*.backup.log usage_statistics_webtalk.*
	-grep -B4 -A10 'Slice LUTs' $@.log
	-grep -B1 -A9 ^Slack $@.log && echo

ld-hw: prog_$(PROG_TARGET)

prog_%:
	$(VIVADO) -nojournal -log $@.log -mode batch -source $@.tcl
	rm -rf .Xil fsm_encoding.os synth_*.backup.log usage_statistics_webtalk.*

firmware.hex:
	make -C $(TEST_DIR) DEFINE="$(DEFINE)"
	cp $(TEST_DIR)/firmware_0.hex ./firmware_0.dat
	cp $(TEST_DIR)/firmware_1.hex ./firmware_1.dat
	cp $(TEST_DIR)/firmware_2.hex ./firmware_2.dat
	cp $(TEST_DIR)/firmware_3.hex ./firmware_3.dat

boot.hex:
	make -C $(BOOT_DIR) DEFINE="$(DEFINE)"
	cp $(BOOT_DIR)/boot_0.hex ./boot_0.dat
	cp $(BOOT_DIR)/boot_1.hex ./boot_1.dat
	cp $(BOOT_DIR)/boot_2.hex ./boot_2.dat
	cp $(BOOT_DIR)/boot_3.hex ./boot_3.dat

clean:
	@rm -rf .Xil/ firmware.bin firmware.elf *.hex *.dat firmware.map synth_*.log 
	@rm -rf *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*#
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb table.txt tab_*/ webtalk.jou
	@rm -rf webtalk.log webtalk_*.jou webtalk_*.log xelab.* xsim[._]* xvlog.*
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf *.jou *.log
	@rm -rf uart_loader
	@rm -rf *.ltx
	make -C $(TEST_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory
