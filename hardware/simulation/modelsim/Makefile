FIRM_DIR = ../../software/firmware
BOOT_DIR = ../../software/bootloader
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart
FIFO_DIR = ../../submodules/fifo
PYTHON_DIR := ../../software/python

BAUD = 1000000


MODULE=system

VLIB=vlib
VCC=vlog
VCC_VHDL=vcom
VSIM=vsim

SV_FLAGS=-sv

GEN_DIR=./gen
MS_LIB=$(GEN_DIR)/modelsim_lib

MS_INT_FILE = $(MS_LIB)/int_file
VCC_LOG_FILE=$(GEN_DIR)/vcc_msgs.txt
TOPLEVEL=$(MODULE)_tb

SRC := $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/*.v $(FIFO_DIR)/*.v
SV_SRC := $(RTL_DIR)/testbench/system_tb.v
INCLUDE+=+incdir+../../rtl/include
INCLUDE+=+incdir+$(UART_DIR)/rtl/include
DEFINES+=+defmacro+MODELSIM
#DEFINES+=+defmacro+FUSION_DEBUG
#DEFINES+=+defmacro+DEBUG
#DEFINES+=+defmacro+DESPERATE_DEBUG
DEFINES+=+defmacro+WARNING_MSGS_ON
DEFINES+=+defmacro+SIMULATION
DEFINES+=+defmacro+UART_BAUD_RATE=$(BAUD)

SIM_LOG_FILE=$(GEN_DIR)/msgs.txt
VSIM_SCRIPT=$(GEN_DIR)/vsim_script
VSIM_SCRIPT_COMMANDS="vsim $(TOPLEVEL);\
		      run -all;\
                      exit"
VSIM_FLAGS=-c -l $(SIM_LOG_FILE) -lib $(MS_LIB) -do $(VSIM_SCRIPT)

all: $(SIM_LOG_FILE)

$(SIM_LOG_FILE): $(MS_INT_FILE) $(VSIM_SCRIPT)
	rm -rf $(SIM_LOG_FILE)
	$(VSIM) $(VSIM_FLAGS)
	@!(cat $@ | grep FAILED && rm -rf $^)
	@(cat $@ | grep PASSED)

$(VSIM_SCRIPT): $(MS_INT_FILE) $(HEX) $(BOOTHEX)
	echo $(VSIM_SCRIPT_COMMANDS)|sed -e 's/ *; */\n/g' > $@

$(MS_INT_FILE): $(MS_LIB) $(SRC) $(SV_SRC) firmware.hex boot.hex
	$(VCC) $(INCLUDE) $(DEFINES) -work $< $(SRC) > $(VCC_LOG_FILE)
	$(VCC) $(SV_FLAGS) $(INCLUDE) $(DEFINES) -work $< $(SV_SRC) >> $(VCC_LOG_FILE)
	@touch $@

$(MS_LIB):
	mkdir -p $(GEN_DIR)
	$(VLIB) $@

#GET FIRMWARE
firmware.hex:
	make -C $(FIRM_DIR) BAUD=$(BAUD)
	cp $(FIRM_DIR)/firmware.hex .
	$(PYTHON_DIR)/hex_split.py firmware

#GET BOOTROM
ifeq ($(shell grep USE_ $(RTL_DIR)/include/system.vh | grep -v \/\/),)
	cp $(FIRM_DIR)/firmware.hex boot.hex
else 
	make -C $(BOOT_DIR) BAUD=$(BAUD)
	cp $(BOOT_DIR)/boot.hex .
endif
	$(PYTHON_DIR)/hex_split.py boot

clean:
	rm -Rf *.vcd .*.swp .*.*.swp *.wlf $(SIM_LOG_FILE) $(MS_LIB) $(VSIM_SCRIPT) work transcript $(MS_INT_FILE) $(VCC_LOG_FILE) $(GEN_DIR)/* $(GEN_DIR) 
	rm -Rf *.dat *.hex *~ 
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
