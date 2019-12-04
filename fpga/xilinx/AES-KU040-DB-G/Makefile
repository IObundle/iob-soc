#hardware configuration
USE_RAM = 0
USE_DDR = 0

ifeq ($(USE_RAM),1)
HWDEFINE := USE_RAM_1
else
HWDEFINE := USE_RAM_0
endif	

ifeq ($(USE_DDR),1)
HWDEFINE += USE_DDR_1
else
HWDEFINE += USE_DDR_0
endif

#hardware paths
RTL_DIR = ../../../rtl
RISCV_DIR = ../../../submodules/iob-rv32
UART_DIR = ../../../submodules/iob-uart
FIFO_DIR = ../../../submodules/fifo

VSRC = $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v


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

#
#software configuration
#
TEST_DIR := ../../../software/hello_world
BOOT_DIR := ../../../software/bootloader
BAUD = 115200

#software defines
DEFINE = -DUART_BAUD_RATE=$(BAUD)

ifeq ($(USE_RAM),1)
DEFINE += -DUSE_RAM
endif	

ifeq ($(USE_DDR),1)
DEFINE += -DUSE_DDR
endif

synth_system.bit: firmware boot *.xdc $(VSRC)
	rm -f $@.log
	$(VIVADO) -nojournal -log $@.log -mode batch -source synth_system.tcl -tclargs $(HWDEFINE)
	-grep -B4 -A10 'Slice LUTs' $@.log
	-grep -B1 -A9 ^Slack $@.log && echo
	scp -P 1418 $@ ${USER}@iobundle.ddns.net:sandbox/iob-soc-e/fpga/xilinx/AES-KU040-DB-G

ld-hw:
	$(VIVADO) -nojournal -log $@.log -mode batch -source $@.tcl
	rm -rf .Xil fsm_encoding.os synth_*.backup.log usage_statistics_webtalk.*

firmware:
	make -C $(TEST_DIR) DEFINE="$(DEFINE)"
	cp $(TEST_DIR)/firmware.hex .
	cp $(TEST_DIR)/firmware_0.hex ./firmware_0.dat
	cp $(TEST_DIR)/firmware_1.hex ./firmware_1.dat
	cp $(TEST_DIR)/firmware_2.hex ./firmware_2.dat
	cp $(TEST_DIR)/firmware_3.hex ./firmware_3.dat

boot: 
ifeq ($(USE_RAM)$(USE_DDR),00)
	cp $(TEST_DIR)/firmware_0.hex ./boot_0.dat
	cp $(TEST_DIR)/firmware_1.hex ./boot_1.dat
	cp $(TEST_DIR)/firmware_2.hex ./boot_2.dat
	cp $(TEST_DIR)/firmware_3.hex ./boot_3.dat
else 
	make -C $(BOOT_DIR) DEFINE="$(DEFINE)"
	cp $(BOOT_DIR)/boot_0.hex ./boot_0.dat
	cp $(BOOT_DIR)/boot_1.hex ./boot_1.dat
	cp $(BOOT_DIR)/boot_2.hex ./boot_2.dat
	cp $(BOOT_DIR)/boot_3.hex ./boot_3.dat
endif

clean:
	@rm -rf .Xil/ *.hex *.dat *.map synth_*.log 
	@rm -rf *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*#
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb 
	@rm -rf table.txt tab_*/ *webtalk* *.jou *.log
	@rm -rf xelab.* xsim[._]* xvlog.* uart_loader
	@rm -rf *.ltx fsm_encoding.os
	make -C $(TEST_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory

.PHONY: clean boot firmware
